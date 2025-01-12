import Foundation
import FirebaseFirestore

final class FirestoreService: FirestoreServiceProtocol {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private init() {}
    
    func create<T: Codable>(_ item: T, in collection: String, withId id: String, userId: String) async throws {
        let docRef = db.collection("users").document(userId).collection(collection).document(id)
        let data = try Firestore.Encoder().encode(item)
        try await docRef.setData(data)
    }
    
    func update<T: Codable>(_ item: T, in collection: String, withId id: String, userId: String) async throws {
        let docRef = db.collection("users").document(userId).collection(collection).document(id)
        let data = try Firestore.Encoder().encode(item)
        try await docRef.setData(data, merge: true)
    }
    
    func delete(from collection: String, withId id: String, userId: String) async throws {
        let docRef = db.collection("users").document(userId).collection(collection).document(id)
        try await docRef.delete()
    }
    
    func get<T: Codable>(from collection: String, withId id: String, userId: String) async throws -> T {
        let docRef = db.collection("users").document(userId).collection(collection).document(id)
        let snapshot = try await docRef.getDocument()
        
        guard snapshot.exists else {
            throw FirestoreError.documentNotFound
        }
        
        return try snapshot.data(as: T.self)
    }
    
    func getAll<T: Codable>(from collection: String, userId: String) async throws -> [T] {
        let collectionRef = db.collection("users").document(userId).collection(collection)
        let snapshot = try await collectionRef.getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: T.self)
        }
    }
    
    func getWordsInBox(box: Int, userId: String) async throws -> [Word] {
        let collectionRef = db.collection("users").document(userId).collection("words")
        let snapshot = try await collectionRef.whereField("box", isEqualTo: box).getDocuments()
        
        return try snapshot.documents.compactMap { document in
            var word = try document.data(as: Word.self)
            word.id = document.documentID
            return word
        }
    }
    
    func updateWordBox(wordId: String, newBox: Int, userId: String) async throws {
        let docRef = db.collection("users").document(userId).collection("words").document(wordId)
        
        // Önce dokümanın var olup olmadığını kontrol et
        let snapshot = try await docRef.getDocument()
        guard snapshot.exists else {
            print("FirestoreService - Belge bulunamadı: \(wordId)")
            throw FirestoreError.documentNotFound
        }
        
        let now = Date()
        let nextReviewDate = Word.calculateNextReviewDate(for: newBox, from: now)
        
        do {
            try await docRef.updateData([
                "box": newBox,
                "last_reviewed_at": Timestamp(date: now),
                "next_review_date": Timestamp(date: nextReviewDate)
            ])
            print("FirestoreService - Kelime kutusu güncellendi: \(wordId) -> Kutu \(newBox)")
            print("FirestoreService - Bir sonraki tekrar tarihi: \(nextReviewDate)")
        } catch {
            print("FirestoreService - Güncelleme hatası: \(error.localizedDescription)")
            throw error
        }
    }
    
    func setupInitialUserData(userId: String) async throws {
        let userDocRef = db.collection("users").document(userId)
        
        try await userDocRef.setData([
            "created_at": FieldValue.serverTimestamp(),
            "last_login_at": FieldValue.serverTimestamp(),
            Constants.dailyWordLimitKey: 0,
            Constants.lastWordAddDateKey: FieldValue.serverTimestamp(),
            "is_premium": false
        ], merge: false)
        
        let collections = ["words", "settings", "statistics"]
        for collection in collections {
            let tempDoc = userDocRef.collection(collection).document()
            try await tempDoc.setData([:])
            try await tempDoc.delete()
        }
        
        let doc = try await userDocRef.getDocument()
        if let count = doc.data()?[Constants.dailyWordLimitKey] as? Int {
            print("Initial daily word count set to:", count)
        }
    }
    
    func addWord(_ word: Word, userId: String) async throws {
        let user = try await getUserData(userId: userId)

        // Bugünün tarihi
        let today = Date().formattedDate(format: "dd MM yyyy")

        if let lastAddDate = user.lastWordAddDate {
            // lastWordAddDate bir Date olduğundan, formatlanarak String'e çevrilir
            let lastAddDay = lastAddDate.formattedDate(format: "dd MM yyyy")
            let isSameDay = lastAddDay == today

            print("Last add date:", lastAddDay)
            print("Today:", today)
            print("Is same day:", isSameDay)

            if !isSameDay {
                print("Resetting daily word count - new day")
                try await resetDailyWordCount(userId: userId)
            }
        } else {
            print("First word of the day - no last add date")
        }

        // Günlük kelime limitini kontrol et
        if user.dailyWordCount >= Constants.dailyWordLimit && !user.isPremium {
            print("Günlük kelime limiti aşıldı, premium ekranına yönlendiriliyor...")
            throw FirestoreError.limitExceeded
        }

        let wordRef = db.collection("users").document(userId)
            .collection("words").document()

        var wordData = word.dictionary
        wordData["id"] = wordRef.documentID
        wordData["createdAt"] = FieldValue.serverTimestamp()

        try await wordRef.setData(wordData)

        try await updateDailyWordCount(userId: userId)
    }
    
    private func resetDailyWordCount(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let now = Date().formattedDate(format: "dd MM yyyy")
        
        try await userRef.updateData([
            Constants.dailyWordLimitKey: 0,
            Constants.lastWordAddDateKey: now
        ])
        
        print("Reset daily word count at:", now)
    }
    
    private func updateDailyWordCount(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            let document = try! transaction.getDocument(userRef)
            let currentCount = document.data()?[Constants.dailyWordLimitKey] as? Int ?? 0
            let newCount = currentCount + 1
            let now = Date().formattedDate(format: "dd MM yyyy")
            
            print("Transaction - Previous count:", currentCount)
            print("Transaction - New count:", newCount)
            
            transaction.updateData([
                Constants.dailyWordLimitKey: newCount,
                Constants.lastWordAddDateKey: now
            ], forDocument: userRef)
            
            return nil
        })
    }
    
    func getUserData(userId: String) async throws -> User {
        let docRef = db.collection("users").document(userId)
        let document = try await docRef.getDocument(source: .server)
        
        guard let data = document.data() else {
            throw FirestoreError.documentNotFound
        }
        
        var userData: [String: Any] = [
            "id": userId,
            "email": data["email"] as? String ?? "",
            "display_name": data["display_name"] as Any,
            "photo_url": data["photo_url"] as Any,
            "is_premium": data["is_premium"] as? Bool ?? false,
            Constants.dailyWordLimitKey: data[Constants.dailyWordLimitKey] as? Int ?? 0
        ]
        
        if let createdAt = data["created_at"] as? Timestamp {
            userData["created_at"] = createdAt.dateValue().timeIntervalSince1970
        }
        
        if let lastWordAddDate = data[Constants.lastWordAddDateKey] as? Timestamp {
            userData[Constants.lastWordAddDateKey] = lastWordAddDate.dateValue().timeIntervalSince1970
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: userData)
        let user = try JSONDecoder().decode(User.self, from: jsonData)
        
        return user
    }
    
    func updateUserFields(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        try await userRef.updateData([
            Constants.dailyWordLimitKey: 0,
            Constants.lastWordAddDateKey: FieldValue.serverTimestamp()
        ])
    }
    
    func deleteUserData(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        // Alt koleksiyonları sil
        let collections = ["words", "settings", "statistics"]
        for collection in collections {
            let snapshot = try await userRef.collection(collection).getDocuments()
            for document in snapshot.documents {
                try await document.reference.delete()
            }
        }
        
        // Kullanıcı dokümanını sil
        try await userRef.delete()
    }
}

extension Double {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}

enum FirestoreError: Error {
    case limitExceeded
    case documentNotFound
    case invalidData
    
    var message: String {
        switch self {
        case .limitExceeded:
            return "Günlük kelime ekleme limitine ulaştınız. Premium'a yükselerek sınırsız kelime ekleyebilirsiniz."
        case .documentNotFound:
            return "Kelime veritabanında bulunamadı. Lütfen kelime listesini yenileyip tekrar deneyin."
        case .invalidData:
            return "Geçersiz veri formatı"
        }
    }
}
