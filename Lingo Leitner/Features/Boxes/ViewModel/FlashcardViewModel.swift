import Foundation

final class FlashcardViewModel {
    // MARK: - Properties
    private let firestoreService: FirestoreServiceProtocol
    private let authManager: AuthManager
    let currentWord: Word
    
    // MARK: - Init
    init(
        word: Word,
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authManager: AuthManager = .shared
    ) {
        self.currentWord = word
        self.firestoreService = firestoreService
        self.authManager = authManager
    }
    
    // MARK: - Public Methods
    func moveWordToNextBox() async throws {
        guard let userId = authManager.currentUser?.id else {
            throw AuthError.userNotFound
        }
        
        let nextBox = min(currentWord.box + 1, 5)
        try await firestoreService.updateWordBox(
            wordId: currentWord.id,
            newBox: nextBox,
            userId: userId
        )
    }
    
    func moveWordToPreviousBox() async throws {
        guard let userId = authManager.currentUser?.id else {
            throw AuthError.userNotFound
        }
        
        let previousBox = max(currentWord.box - 1, 1)
        try await firestoreService.updateWordBox(
            wordId: currentWord.id,
            newBox: previousBox,
            userId: userId
        )
    }
} 