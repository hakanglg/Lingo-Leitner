import Foundation

protocol NotificationsViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didReceiveError(_ error: Error)
}

final class NotificationsViewModel {
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authManager: AuthManager
    weak var delegate: NotificationsViewModelDelegate?
    
    private(set) var dueWords: [Word] = []
    
    // MARK: - Init
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authManager: AuthManager = .shared
    ) {
        self.firestoreService = firestoreService
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func fetchNotifications() async {
        guard let userId = authManager.currentUser?.id else {
            delegate?.didReceiveError(AuthError.userNotFound)
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.didStartLoading()
        }
        
        do {
            var allDueWords: [Word] = []
            
            // Tüm kutulardaki kelimeleri kontrol et
            for box in 1...5 {
                let words = try await firestoreService.getWordsInBox(box: box, userId: userId)
                let dueWordsInBox = words.filter { $0.needsReview }
                allDueWords.append(contentsOf: dueWordsInBox)
            }
            
            dueWords = allDueWords
            
            DispatchQueue.main.async {
                self.delegate?.didFinishLoading()
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.didReceiveError(error)
            }
        }
    }
} 