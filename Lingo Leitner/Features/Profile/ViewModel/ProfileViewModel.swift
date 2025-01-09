import Foundation

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
            delegate?.didReceiveError(AuthError.userNotFound)
            return
        }
        
        delegate?.didUpdateProfile(user)
        
        do {
            // Tüm kutulardaki kelimeleri al
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
            
            delegate?.didUpdateStats(stats)
        } catch {
            delegate?.didReceiveError(error)
        }
    }
    
    func signOut() async {
        do {
            try authManager.signOut()
            DispatchQueue.main.async {
                // Çıkış yapıldığında bildirim gönder
                NotificationCenter.default.post(name: .userDidSignOut, object: nil)
            }
        } catch {
            delegate?.didReceiveError(error)
        }
    }
} 