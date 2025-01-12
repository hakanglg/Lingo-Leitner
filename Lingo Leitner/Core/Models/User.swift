import Foundation

struct User: Codable {
    let id: String
    let email: String
    let displayName: String?
    let photoURL: URL?
    let isPremium: Bool
    let createdAt: Date
    let dailyWordCount: Int
    let lastWordAddDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case photoURL = "photo_url"
        case isPremium = "is_premium"
        case createdAt = "created_at"
        case dailyWordCount = "daily_word_count"
        case lastWordAddDate = "last_word_add_date"
    }
    
    init(
        id: String,
        email: String,
        displayName: String? = nil,
        photoURL: URL? = nil,
        isPremium: Bool = false,
        createdAt: Date = Date(),
        dailyWordCount: Int = 0,
        lastWordAddDate: Date? = nil
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isPremium = isPremium
        self.createdAt = createdAt
        self.dailyWordCount = dailyWordCount
        self.lastWordAddDate = lastWordAddDate
    }
}

// Firebase için extension
extension User {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName)
        
        // photoURL'i URL tipine çevir
        if let urlString = try container.decodeIfPresent(String.self, forKey: .photoURL) {
            photoURL = URL(string: urlString)
        } else {
            photoURL = nil
        }
        
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        dailyWordCount = try container.decode(Int.self, forKey: .dailyWordCount)
        lastWordAddDate = try container.decodeIfPresent(Date.self, forKey: .lastWordAddDate)
        
        // Unix timestamp'i Date'e çevir
        let timestamp = try container.decode(Double.self, forKey: .createdAt)
        createdAt = Date(timeIntervalSince1970: timestamp)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(displayName, forKey: .displayName)
        try container.encodeIfPresent(photoURL?.absoluteString, forKey: .photoURL)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encode(createdAt.timeIntervalSince1970, forKey: .createdAt)
        try container.encode(dailyWordCount, forKey: .dailyWordCount)
        try container.encodeIfPresent(lastWordAddDate, forKey: .lastWordAddDate)
    }
} 