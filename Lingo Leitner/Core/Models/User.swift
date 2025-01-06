import Foundation

struct User: Codable {
    let id: String
    let email: String
    let displayName: String?
    let photoURL: String?
    let isPremium: Bool
    let createdAt: Date
    
    init(id: String, email: String, displayName: String?, photoURL: String?, isPremium: Bool, createdAt: Date) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isPremium = isPremium
        self.createdAt = createdAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case photoURL = "photo_url"
        case isPremium = "is_premium"
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        
        if let timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .createdAt) {
            createdAt = Date(timeIntervalSince1970: timestamp)
        } else {
            createdAt = Date()
        }
    }
} 