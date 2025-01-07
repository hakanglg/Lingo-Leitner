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
            try document.data(as: Word.self)
        }
    }
    
    func updateWordBox(wordId: String, newBox: Int, userId: String) async throws {
        let docRef = db.collection("users").document(userId).collection("words").document(wordId)
        try await docRef.updateData([
            "box": newBox,
            "lastReviewedAt": Timestamp(date: Date())
        ])
    }
    
    func setupInitialUserData(userId: String) async throws {
        let userDocRef = db.collection("users").document(userId)
        
        // Kullanıcı dokümanını oluştur
        try await userDocRef.setData([
            "createdAt": Timestamp(date: Date()),
            "lastLoginAt": Timestamp(date: Date())
        ], merge: true)
        
        // Koleksiyonları oluştur
        let collections = ["words", "settings", "statistics"]
        for collection in collections {
            // Boş bir doküman oluşturup sil (koleksiyonu başlatmak için)
            let tempDoc = userDocRef.collection(collection).document()
            try await tempDoc.setData([:])
            try await tempDoc.delete()
        }
    }
}

enum FirestoreError: LocalizedError {
    case documentNotFound
    
    var errorDescription: String? {
        switch self {
        case .documentNotFound:
            return "Belge bulunamadı"
        }
    }
} 
