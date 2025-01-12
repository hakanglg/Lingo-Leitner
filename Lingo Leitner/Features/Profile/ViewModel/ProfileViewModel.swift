import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol ProfileViewModelDelegate: AnyObject {
    func didUpdateUserData(_ user: User, stats: UserStats)
    func didLogout()
    func didReceiveError(_ error: Error)
}

final class ProfileViewModel {
    
    // MARK: - Properties
    weak var delegate: ProfileViewModelDelegate?
    private let authManager: AuthManager
    
    // MARK: - Init
    init(authManager: AuthManager = AuthManager.shared) {
        self.authManager = authManager
    }
    
    // MARK: - Methods
    func fetchUserData() async {
        do {
            guard let currentUser = Auth.auth().currentUser else {
                throw AuthError.userNotFound
            }
            
            // Kullanıcı verilerini al
            let user = User(
                id: currentUser.uid,
                email: currentUser.email ?? "",
                displayName: currentUser.displayName,
                photoURL: currentUser.photoURL
            )
            
            // İstatistikleri hesapla
            let stats = try await calculateUserStats(userId: user.id)
            
            await MainActor.run {
                delegate?.didUpdateUserData(user, stats: stats)
            }
        } catch {
            await MainActor.run {
                delegate?.didReceiveError(error)
            }
        }
    }
    
    private func calculateUserStats(userId: String) async throws -> UserStats {
        let db = Firestore.firestore()
        
        // Tüm kutuları kontrol et
        var totalWords = 0
        var masteredWords = 0
        
        // Her kutudaki kelimeleri say
        for box in 1...5 {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("words")
                .whereField("box", isEqualTo: box)
                .getDocuments()
            
            let wordsInBox = snapshot.documents.count
            totalWords += wordsInBox
            
            // 5. kutudaki kelimeler öğrenilmiş sayılır
            if box == 5 {
                masteredWords = wordsInBox
            }
        }
        
        // Günlük seriyi hesapla
        let userDoc = try await db.collection("users").document(userId).getDocument()
        let userData = userDoc.data()
        
        let currentStreak = userData?["current_streak"] as? Int ?? 0
        let lastReviewDate = (userData?["last_review_date"] as? Timestamp)?.dateValue()
        
        return UserStats(
            totalWords: totalWords,
            masteredWords: masteredWords,
            currentStreak: currentStreak,
            lastReviewDate: lastReviewDate
        )
    }
    
    func logout() async {
        do {
            try await authManager.signOut()
            
            await MainActor.run {
                delegate?.didLogout()
            }
        } catch {
            await MainActor.run {
                delegate?.didReceiveError(error)
            }
        }
    }
} 
