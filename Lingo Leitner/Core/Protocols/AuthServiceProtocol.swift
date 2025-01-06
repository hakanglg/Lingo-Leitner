import Foundation
import UIKit
import FirebaseAuth

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    func signIn(with email: String, password: String) async throws -> User
    func signUp(with email: String, password: String) async throws -> User
    func signInWithGoogle(presenting: UIViewController) async throws -> User
    func signInWithApple() async throws -> User
    func signOut() throws
    func updateProfile(displayName: String?, photoURL: URL?) async throws
    func deleteAccount() async throws
} 
