import Foundation

protocol AddWordViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didReceiveError(_ error: Error)
    func didSaveWordSuccessfully()
}

final class AddWordViewModel {
    weak var delegate: AddWordViewModelDelegate?
    private let firestoreService: FirestoreServiceProtocol
    private let authManager: AuthManager
    
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authManager: AuthManager = .shared
    ) {
        self.firestoreService = firestoreService
        self.authManager = authManager
    }
    
    // MARK: - Validation
    func validateWord(_ word: String) -> Bool {
        guard !word.isEmpty else { return false }
        guard word.count >= 2 else { return false }
        let pattern = "^[a-zA-ZğüşıöçĞÜŞİÖÇ\\s'-]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(word.startIndex..., in: word)
        return regex?.firstMatch(in: word, range: range) != nil
    }
    
    func validateMeaning(_ meaning: String) -> Bool {
        return !meaning.isEmpty && meaning.count >= 2
    }
    
    // MARK: - Save Word
    func saveWord(word: String, meaning: String, example: String?, difficulty: Difficulty) async {
        guard let userId = authManager.currentUser?.id else {
            delegate?.didReceiveError(AuthError.userNotFound)
            return
        }
        
        DispatchQueue.main.async {
            self.delegate?.didStartLoading()
        }
        
        do {
            let newWord = Word(
                word: word,
                meaning: meaning,
                example: example,
                difficulty: difficulty
            )
            
            try await firestoreService.create(newWord, in: "words", withId: newWord.id, userId: userId)
            
            DispatchQueue.main.async {
                self.delegate?.didFinishLoading()
                self.delegate?.didSaveWordSuccessfully()
            }
        } catch {
            DispatchQueue.main.async {
                self.delegate?.didReceiveError(error)
            }
        }
    }
}

enum ValidationError: LocalizedError {
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Lütfen tüm alanları doğru formatta doldurun"
        }
    }
} 