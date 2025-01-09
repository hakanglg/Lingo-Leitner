import UIKit

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    
    func signIn(with email: String, password: String) async throws -> User
    func signUp(with email: String, password: String, displayName: String?) async throws -> User
    func signInWithGoogle(presenting: UIViewController) async throws -> User
    func signInWithApple() async throws -> User
    func resetPassword(for email: String) async throws
    func signOut() throws
    func deleteAccount() async throws
} 
