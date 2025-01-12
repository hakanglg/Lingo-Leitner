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
    func saveWord(word: String, meaning: String, example: String?) async {
        await MainActor.run {
            delegate?.didStartLoading()
        }
        
        do {
            guard let userId = authManager.currentUser?.id else {
                await MainActor.run {
                    delegate?.didFinishLoading()
                    delegate?.didReceiveError(AuthError.userNotFound)
                }
                return
            }
            
            let newWord = Word(
                word: word,
                meaning: meaning,
                example: example
            )
            
            try await firestoreService.addWord(newWord, userId: userId)
            
            await MainActor.run {
                delegate?.didSaveWordSuccessfully()
            }
        } catch {
            await MainActor.run {
                delegate?.didFinishLoading()
                delegate?.didReceiveError(error)
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