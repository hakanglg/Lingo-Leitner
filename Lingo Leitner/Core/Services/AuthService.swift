import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UIKit
import AuthenticationServices
import CryptoKit

final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    private let db = Firestore.firestore()
    private init() {}
    
    var currentUser: User? {
        guard let firebaseUser = Auth.auth().currentUser else { return nil }
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL?.absoluteString,
            isPremium: false,
            createdAt: Date()
        )
    }
    
    func signIn(with email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let userData = try await getUserData(uid: result.user.uid)
        return userData
    }
    
    func signUp(with email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let user = User(
            id: result.user.uid,
            email: email,
            displayName: nil,
            photoURL: nil,
            isPremium: false,
            createdAt: Date()
        )
        try await saveUserData(user)
        return user
    }
    
    @MainActor
    func signInWithGoogle(presenting: UIViewController) async throws -> User {
        print("Google Sign In başlatılıyor...")
        
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Client ID bulunamadı")
            throw AuthError.unknown
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            print("Google Sign In dialog'u açılıyor...")
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
            
            guard let idToken = result.user.idToken?.tokenString else {
                print("ID Token alınamadı")
                throw AuthError.signInFailed
            }
            
            print("Google kimlik doğrulama başarılı, Firebase'e giriş yapılıyor...")
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            print("Firebase'e giriş başarılı")
            
            let user = User(
                id: authResult.user.uid,
                email: authResult.user.email ?? "",
                displayName: authResult.user.displayName,
                photoURL: authResult.user.photoURL?.absoluteString,
                isPremium: false,
                createdAt: Date()
            )
            
            try await saveUserData(user)
            return user
        } catch {
            print("Google Sign In hatası: \(error.localizedDescription)")
            throw AuthError.signInFailed
        }
    }
    
    func signInWithApple() async throws -> User {
        // Apple Developer hesabı gerektiği için şimdilik devre dışı
        throw AuthError.notImplemented
        
        /* 
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
        }
        
        guard let appleIDCredential = result as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            throw AuthError.signInFailed
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        
        // Kullanıcı bilgilerini güncelle (ilk giriş için)
        if let fullName = appleIDCredential.fullName {
            let displayName = PersonNameComponentsFormatter().string(from: fullName)
            try await Auth.auth().currentUser?.updateProfile(displayName: displayName)
        }
        
        let user = User(
            id: authResult.user.uid,
            email: authResult.user.email ?? "",
            displayName: authResult.user.displayName,
            photoURL: authResult.user.photoURL?.absoluteString,
            isPremium: false,
            createdAt: Date()
        )
        
        try await saveUserData(user)
        return user
        */
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func updateProfile(displayName: String?, photoURL: URL?) async throws {
        let request = Auth.auth().currentUser?.createProfileChangeRequest()
        request?.displayName = displayName
        request?.photoURL = photoURL
        try await request?.commitChanges()
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        try await updateUserData(uid: uid, ["display_name": displayName, "photo_url": photoURL?.absoluteString])
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else { throw AuthError.userNotFound }
        try await user.delete()
    }
    
    // MARK: - Private Methods
    private func getUserData(uid: String) async throws -> User {
        let docRef = db.collection("users").document(uid)
        let document = try await docRef.getDocument()
        
        guard let data = document.data() else {
            throw AuthError.userNotFound
        }
        
        // Firestore'dan gelen Timestamp'i Date'e çevirelim
        var userData = data
        if let createdAt = data["created_at"] as? Timestamp {
            userData["created_at"] = createdAt.dateValue().timeIntervalSince1970
        }
        
        // JSON serileştirme için güvenli dönüşüm
        let jsonData = try JSONSerialization.data(withJSONObject: userData)
        return try JSONDecoder().decode(User.self, from: jsonData)
    }
    
    private func saveUserData(_ user: User) async throws {
        let data: [String: Any] = [
            "id": user.id,
            "email": user.email,
            "display_name": user.displayName as Any,
            "photo_url": user.photoURL as Any,
            "is_premium": user.isPremium,
            "created_at": Timestamp(date: user.createdAt)
        ]
        
        try await db.collection("users").document(user.id).setData(data)
    }
    
    private func updateUserData(uid: String, _ data: [String: Any?]) async throws {
        let filteredData = data.compactMapValues { $0 }
        try await db.collection("users").document(uid).updateData(filteredData)
    }
    
    // Helper metodlar
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
                if remainingLength == 0 { return }
                
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
