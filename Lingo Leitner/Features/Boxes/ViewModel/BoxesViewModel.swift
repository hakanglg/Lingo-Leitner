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
    
    private var wordCounts: [Int: Int] = [:] // [boxNumber: count]
    private var reviewCounts: [Int: Int] = [:] // [boxNumber: reviewCount]
    
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
            delegate?.didReceiveError(AuthError.userNotFound)
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.didStartLoading()
        }
        
        do {
            for boxNumber in 1...5 {
                let words = try await firestoreService.getWordsInBox(box: boxNumber, userId: userId)
                wordCounts[boxNumber] = words.count
                reviewCounts[boxNumber] = words.filter { $0.needsReview }.count
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
    
    func wordCount(forBox boxNumber: Int) -> Int {
        return wordCounts[boxNumber] ?? 0
    }
    
    func reviewCount(forBox boxNumber: Int) -> Int {
        return reviewCounts[boxNumber] ?? 0
    }
} 