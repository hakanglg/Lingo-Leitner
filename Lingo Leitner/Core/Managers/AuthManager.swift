import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

final class AuthManager {
    static let shared = AuthManager()
    private let authService = AuthService.shared
    private init() {}
    
    var currentUser: User? {
        return authService.currentUser
    }
    
    // MARK: - Email/Password Auth
    func signUp(email: String, password: String) async throws {
        do {
            _ = try await authService.signUp(with: email, password: password)
            print("Kullanıcı oluşturuldu")
        } catch {
            throw handleAuthError(error)
        }
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            _ = try await authService.signIn(with: email, password: password)
            print("Giriş yapıldı")
        } catch {
            throw handleAuthError(error)
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle(presenting: UIViewController) async throws {
        print("AuthManager: Google Sign In başlatılıyor...")
        do {
            print("AuthManager: AuthService.signInWithGoogle çağrılıyor...")
            let user = try await authService.signInWithGoogle(presenting: presenting)
            print("AuthManager: Google ile giriş başarılı. Kullanıcı: \(user.email)")
        } catch {
            print("AuthManager: Google Sign In hatası: \(error.localizedDescription)")
            throw handleAuthError(error)
        }
    }
    
    // MARK: - Apple Sign In
    func signInWithApple() async throws {
        do {
            _ = try await authService.signInWithApple()
            print("Apple ile giriş yapıldı")
        } catch {
            throw handleAuthError(error)
        }
    }
    
    func signOut() throws {
        do {
            try authService.signOut()
            print("Çıkış yapıldı")
        } catch {
            throw AuthError.unknown
        }
    }
    
    private func handleAuthError(_ error: Error) -> AuthError {
        if let authError = error as? AuthError {
            return authError
        }
        
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        default:
            return .unknown
        }
    }
} 
