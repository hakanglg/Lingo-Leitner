import Foundation

protocol BoxesViewModelDelegate: AnyObject {
    func didStartLoading()
    func didFinishLoading()
    func didReceiveError(_ error: Error)
}

@MainActor
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
            delegate?.didReceiveError(AuthError.userNotFound)
            return
        }
        
        delegate?.didStartLoading()
        
        do {
            // Dictionary'leri temizle
            boxCounts.removeAll()
            reviewCounts.removeAll()
            
            // Her kutu için kelimeleri al
            for box in 1...5 {
                do {
                    let words = try await firestoreService.getWordsInBox(box: box, userId: userId)
                    boxCounts[box] = words.count
                    reviewCounts[box] = words.filter { $0.needsReview }.count
                } catch {
                    print("Box \(box) için hata: \(error.localizedDescription)")
                    // Hata olsa bile devam et, sadece o kutuyu 0 olarak işaretle
                    boxCounts[box] = 0
                    reviewCounts[box] = 0
                }
            }
            
            // Her durumda yüklemeyi bitir
            delegate?.didFinishLoading()
        } catch {
            print("Genel hata: \(error.localizedDescription)")
            delegate?.didReceiveError(error)
            // Hata durumunda da yüklemeyi bitir
            delegate?.didFinishLoading()
        }
    }
    
    func wordCount(forBox box: Int) -> Int {
        return boxCounts[box] ?? 0
    }
    
    func reviewCount(forBox box: Int) -> Int {
        return reviewCounts[box] ?? 0
    }
} 