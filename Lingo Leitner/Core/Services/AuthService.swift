import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

final class AuthService: NSObject, AuthServiceProtocol {
    static let shared = AuthService()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private override init() {
        super.init()
    }
    
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
            isPremium: false,
            createdAt: Date(),
            dailyWordCount: 0
        )
    }
    
    func signIn(with email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        
        let user = User(
            id: result.user.uid,
            email: result.user.email ?? "",
            displayName: result.user.displayName,
            photoURL: result.user.photoURL,
            isPremium: false,
            createdAt: Date(),
            dailyWordCount: 0
        )
        
        return user
    }
    
    func signUp(with email: String, password: String, displayName: String?) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        
        if let displayName = displayName {
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = displayName
            try await changeRequest.commitChanges()
        }
        
        let user = User(
            id: result.user.uid,
            email: email,
            displayName: displayName,
            photoURL: nil,
            isPremium: false,
            createdAt: Date(),
            dailyWordCount: 0
        )
        
        try await saveUserData(user)
        return user
    }
    
    func signInWithGoogle(presenting: UIViewController) async throws -> User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.unknown
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.unknown
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        
        let authResult = try await auth.signIn(with: credential)
        
        let user = User(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: authResult.user.displayName,
            photoURL: authResult.user.photoURL,
            isPremium: false,
            createdAt: Date(),
            dailyWordCount: 0
        )
        
        try await saveUserData(user)
        return user
    }
    
    func signInWithApple() async throws -> User {
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let result = try await withCheckedThrowingContinuation { continuation in
            let controller = ASAuthorizationController(authorizationRequests: [request])
            let delegate = AppleSignInDelegate(continuation: continuation)
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
            
            objc_setAssociatedObject(self, "appleSignInDelegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
        
        guard let appleIDCredential = result.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.invalidCredentials
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        let authResult = try await auth.signIn(with: credential)
        
        let user = User(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: authResult.user.displayName,
            photoURL: authResult.user.photoURL,
            isPremium: false,
            createdAt: Date(),
            dailyWordCount: 0
        )
        
        try await saveUserData(user)
        return user
    }
    
    func resetPassword(for email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func deleteAccount() async throws {
        try await auth.currentUser?.delete()
    }
    
    private func saveUserData(_ user: User) async throws {
        try await db.collection("users").document(user.id).setData([
            "email": user.email,
            "display_name": user.displayName as Any,
            "photo_url": user.photoURL?.absoluteString as Any,
            "is_premium": user.isPremium,
            "created_at": user.createdAt.timeIntervalSince1970,
            "daily_word_count": user.dailyWordCount,
            "last_word_add_date": user.lastWordAddDate as Any
        ])
    }
    
    // Apple Sign In için yardımcı metodlar
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// Apple Sign In Delegate
private class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<ASAuthorization, Error>
    
    init(continuation: CheckedContinuation<ASAuthorization, Error>) {
        self.continuation = continuation
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        continuation.resume(returning: authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }
} 
