import Foundation

struct User: Codable {
    let id: String
    let email: String
    let displayName: String?
    let photoURL: String?
    let isPremium: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case photoURL = "photo_url"
        case isPremium = "is_premium"
        case createdAt = "created_at"
    }
    
    init(
        id: String,
        email: String,
        displayName: String? = nil,
        photoURL: String? = nil,
        isPremium: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isPremium = isPremium
        self.createdAt = createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        
        // Unix timestamp'i Date'e çevir
        let timestamp = try container.decode(Double.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: timestamp)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encodeIfPresent(photoURL, forKey: .photoURL)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)
    }
} 