import Foundation
import UIKit

protocol ProfileViewModelDelegate: AnyObject {
    func didUpdateProfile(_ user: User)
    func didUpdateStats(_ stats: UserStats)
    func didReceiveError(_ error: Error)
}

final class ProfileViewModel {
    // MARK: - Properties
    private let authManager: AuthManager
    private let firestoreService: FirestoreServiceProtocol
    weak var delegate: ProfileViewModelDelegate?
    
    // MARK: - Init
    init(
        authManager: AuthManager = .shared,
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared
    ) {
        self.authManager = authManager
        self.firestoreService = firestoreService
    }
    
    // MARK: - Public Methods
    func fetchUserProfile() async {
        guard let user = authManager.currentUser else {
            await MainActor.run {
                delegate?.didReceiveError(AuthError.userNotFound)
            }
            return
        }
        
        await MainActor.run {
            delegate?.didUpdateProfile(user)
        }
        
        do {
            var totalWords = 0
            var masteredWords = 0
            var reviewDueWords = 0
            
            for box in 1...5 {
                let words = try await firestoreService.getWordsInBox(box: box, userId: user.id)
                totalWords += words.count
                masteredWords += words.filter { $0.box == 5 }.count
                reviewDueWords += words.filter { $0.needsReview }.count
            }
            
            let stats = UserStats(
                totalWords: totalWords,
                masteredWords: masteredWords,
                reviewDueWords: reviewDueWords
            )
            
            await MainActor.run {
                delegate?.didUpdateStats(stats)
            }
        } catch {
            await MainActor.run {
                delegate?.didReceiveError(error)
            }
        }
    }
    
    func signOut() async {
        do {
            try authManager.signOut()
            await MainActor.run {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let authVC = AuthViewController()
                    let nav = UINavigationController(rootViewController: authVC)
                    nav.modalPresentationStyle = .fullScreen
                    sceneDelegate.window?.rootViewController = nav
                    sceneDelegate.window?.makeKeyAndVisible()
                }
            }
        } catch {
            await MainActor.run {
                delegate?.didReceiveError(error)
            }
        }
    }
} 
