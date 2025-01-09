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
    
    func signUp(with email: String, password: String, displayName: String?) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        
        // Kullanıcı adını güncelle
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
            createdAt: Date()
        )
        
        try await saveUserData(user)
        return user
    }
    
    func signInWithGoogle(presenting: UIViewController) async throws -> User {
        do {
            // 1. Google Sign In
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw AuthError.unknown
            }
            
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.signInFailed
            }
            
            // 2. Firebase Authentication
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            
            // 3. Kullanıcı Verilerini Hazırla
            let userData: [String: Any] = [
                "id": authResult.user.uid,
                "email": authResult.user.email ?? "",
                "display_name": authResult.user.displayName as Any,
                "photo_url": authResult.user.photoURL?.absoluteString as Any,
                "is_premium": false,
                "created_at": FieldValue.serverTimestamp()
            ]
            
            // 4. Firestore'a Kaydet
            let userRef = db.collection("users").document(authResult.user.uid)
            
            // Batch işlemi başlat
            let batch = db.batch()
            
            // Kullanıcı dokümanını ekle
            batch.setData(userData, forDocument: userRef, merge: true)
            
            // Ayarlar dokümanını ekle
            let settingsRef = userRef.collection("settings").document("preferences")
            batch.setData([
                "notifications_enabled": true,
                "daily_reminder": true,
                "reminder_time": "09:00",
                "theme": "system",
                "created_at": FieldValue.serverTimestamp()
            ], forDocument: settingsRef)
            
            // Batch işlemini commit et
            try await batch.commit()
            
            // 5. User nesnesini döndür
            return User(
                id: authResult.user.uid,
                email: authResult.user.email ?? "",
                displayName: authResult.user.displayName,
                photoURL: authResult.user.photoURL?.absoluteString,
                isPremium: false,
                createdAt: Date()
            )
            
        } catch {
            print("Google Sign In hatası: \(error)")
            if let firestoreError = error as NSError?,
               firestoreError.domain == FirestoreErrorDomain {
                print("Firestore hatası: \(firestoreError.localizedDescription)")
                print("Hata kodu: \(firestoreError.code)")
            }
            throw AuthError.signInFailed
        }
    }
    
    func signInWithApple() async throws -> User {
        // Apple Developer hesabı gerektiği için şimdilik devre dışı
        throw AuthError.notImplemented
    }
    
    func resetPassword(for email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
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
} 
