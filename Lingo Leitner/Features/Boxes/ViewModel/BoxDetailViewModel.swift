import Foundation

protocol BoxDetailViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didReceiveError(_ error: Error)
}

final class BoxDetailViewModel {
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authManager: AuthManager
    weak var delegate: BoxDetailViewModelDelegate?
    
    let boxNumber: Int
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
    
    func moveWordToNextBox(at index: Int) async throws {
        guard let userId = authManager.currentUser?.id else {
            throw AuthError.userNotFound
        }
        
        let word = words[index]
        let nextBox = min(word.box + 1, 5)
        try await firestoreService.updateWordBox(
            wordId: word.id,
            newBox: nextBox,
            userId: userId
        )
    }
    
    func moveWordToPreviousBox(at index: Int) async throws {
        guard let userId = authManager.currentUser?.id else {
            throw AuthError.userNotFound
        }
        
        let word = words[index]
        let previousBox = max(word.box - 1, 1)
        try await firestoreService.updateWordBox(
            wordId: word.id,
            newBox: previousBox,
            userId: userId
        )
    }
} 