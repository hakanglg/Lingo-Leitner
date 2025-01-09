import Foundation

protocol BoxesViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didReceiveError(_ error: Error)
}

final class BoxesViewModel {
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authManager: AuthManager
    weak var delegate: BoxesViewModelDelegate?
    
    private var boxCounts: [Int: Int] = [:]
    private var reviewCounts: [Int: Int] = [:]
    
    // MARK: - Init
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authManager: AuthManager = .shared
    ) {
        self.firestoreService = firestoreService
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func fetchBoxes() async {
        guard let userId = authManager.currentUser?.id else {
            DispatchQueue.main.async {
                self.delegate?.didReceiveError(AuthError.userNotFound)
            }
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.didStartLoading()
        }
        
        do {
            // Her kutu için kelimeleri al
            for box in 1...5 {
                let words = try await firestoreService.getWordsInBox(box: box, userId: userId)
                boxCounts[box] = words.count
                reviewCounts[box] = words.filter { $0.needsReview }.count
            }
            
            DispatchQueue.main.async {
                self.delegate?.didFinishLoading()
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.didReceiveError(error)
            }
        }
    }
    
    func wordCount(forBox box: Int) -> Int {
        return boxCounts[box] ?? 0
    }
    
    func reviewCount(forBox box: Int) -> Int {
        return reviewCounts[box] ?? 0
    }
} 