import Foundation

protocol FirestoreServiceProtocol: AnyObject {
    func create<T: Codable>(_ item: T, in collection: String, withId id: String, userId: String) async throws
    func update<T: Codable>(_ item: T, in collection: String, withId id: String, userId: String) async throws
    func delete(from collection: String, withId id: String, userId: String) async throws
    func get<T: Codable>(from collection: String, withId id: String, userId: String) async throws -> T
    func getAll<T: Codable>(from collection: String, userId: String) async throws -> [T]
    func getWordsInBox(box: Int, userId: String) async throws -> [Word]
    func updateWordBox(wordId: String, newBox: Int, userId: String) async throws
    func setupInitialUserData(userId: String) async throws
    func getUserData(userId: String) async throws -> User
    func updateUserFields(userId: String) async throws
    func addWord(_ word: Word, userId: String) async throws
} 
