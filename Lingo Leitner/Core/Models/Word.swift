import Foundation
import FirebaseFirestore
import UIKit

struct Word: Codable, Equatable {
    var id: String
    let word: String
    let meaning: String
    let example: String?
    var box: Int
    let nextReviewDate: Date?
    let lastReviewedAt: Date?
    
    // Yeni kelime oluşturmak için initializer
    init(id: String = UUID().uuidString,
         word: String,
         meaning: String,
         example: String? = nil,
         box: Int = 1,
         nextReviewDate: Date? = nil,
         lastReviewedAt: Date? = nil) {
        self.id = id
        self.word = word
        self.meaning = meaning
        self.example = example
        self.box = box
        self.nextReviewDate = nextReviewDate
        self.lastReviewedAt = lastReviewedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case word
        case meaning
        case example
        case box
        case nextReviewDate = "next_review_date"
        case lastReviewedAt = "last_reviewed_at"
    }
    
    // Her kutu için tekrar aralıkları (gün cinsinden)
    private static let reviewIntervals = [
        1,    // Kutu 1: Her gün
        2,    // Kutu 2: 2 günde bir
        4,    // Kutu 3: 4 günde bir
        7,    // Kutu 4: 7 günde bir
        14    // Kutu 5: 14 günde bir
    ]
    
    // Bir sonraki tekrar tarihini hesapla
    static func calculateNextReviewDate(for box: Int, from date: Date = Date()) -> Date {
        let interval = reviewIntervals[box - 1]
        return Calendar.current.date(byAdding: .day, value: interval, to: date) ?? date
    }
    
    // Tekrar durumunu hesapla
    var needsReview: Bool {
        guard let nextReview = nextReviewDate else {
            return true // Hiç tekrar edilmemişse tekrar edilmeli
        }
        return Date() >= nextReview
    }
    
    // Tekrar durumunu detaylı olarak hesapla
    var reviewStatus: ReviewStatus {
        guard let nextReview = nextReviewDate else {
            return .due
        }
        
        let now = Date()
        let timeUntilReview = nextReview.timeIntervalSince(now)
        let daysUntilReview = timeUntilReview / (24 * 3600) // Saat yerine gün kullanıyoruz
        
        if timeUntilReview <= 0 {
            return .due
        } else if daysUntilReview <= 1 {
            return .soon
        } else {
            return .upcoming
        }
    }
    
    // Firestore için dictionary dönüşümü
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "word": word,
            "meaning": meaning,
            "box": box
        ]
        
        // Opsiyonel alanları ekle
        if let example = example {
            dict["example"] = example
        }
        if let nextReviewDate = nextReviewDate {
            dict["next_review_date"] = Timestamp(date: nextReviewDate)
        }
        if let lastReviewedAt = lastReviewedAt {
            dict["last_reviewed_at"] = Timestamp(date: lastReviewedAt)
        }
        
        return dict
    }
    
    // Firestore'dan decode etme
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        word = try container.decode(String.self, forKey: .word)
        meaning = try container.decode(String.self, forKey: .meaning)
        example = try container.decodeIfPresent(String.self, forKey: .example)
        box = try container.decode(Int.self, forKey: .box)
        
        // Timestamp'leri Date'e çevir
        if let nextReviewTimestamp = try container.decodeIfPresent(Timestamp.self, forKey: .nextReviewDate) {
            nextReviewDate = nextReviewTimestamp.dateValue()
        } else {
            nextReviewDate = nil
        }
        
        if let lastReviewedTimestamp = try container.decodeIfPresent(Timestamp.self, forKey: .lastReviewedAt) {
            lastReviewedAt = lastReviewedTimestamp.dateValue()
        } else {
            lastReviewedAt = nil
        }
    }
}

extension Word: Comparable {
    static func < (lhs: Word, rhs: Word) -> Bool {
        return lhs.word.localizedCaseInsensitiveCompare(rhs.word) == .orderedAscending
    }
}

enum ReviewStatus {
    case due      // Tekrar vakti gelmiş
    case soon     // 1 gün içinde tekrar edilecek
    case upcoming // Daha sonra tekrar edilecek
    
    var displayText: String {
        switch self {
        case .due:
            return "review_status_due".localized
        case .soon:
            return "review_status_soon".localized
        case .upcoming:
            return "review_status_upcoming".localized
        }
    }
    
    var color: UIColor {
        switch self {
        case .due:
            return .systemRed
        case .soon:
            return .systemOrange
        case .upcoming:
            return .systemGreen
        }
    }
}

