import Foundation

protocol BoxDetailViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didReceiveError(_ error: Error)
}

final class BoxDetailViewModel {
    // MARK: - Properties
    private let boxNumber: Int
    private let firestoreService: FirestoreServiceProtocol
    private let authManager: AuthManager
    weak var delegate: BoxDetailViewModelDelegate?
    
    private(set) var words: [Word] = []
    
    // MARK: - Init
    init(
        boxNumber: Int,
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authManager: AuthManager = .shared
    ) {
        self.boxNumber = boxNumber
        self.firestoreService = firestoreService
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func fetchWords() async {
        guard let userId = authManager.currentUser?.id else {
            delegate?.didReceiveError(AuthError.userNotFound)
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.didStartLoading()
        }
        
        do {
            words = try await firestoreService.getWordsInBox(box: boxNumber, userId: userId)
            
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