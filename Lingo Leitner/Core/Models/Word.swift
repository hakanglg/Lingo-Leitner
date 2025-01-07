import Foundation
import FirebaseFirestore

enum Difficulty: Int, Codable, CaseIterable {
    case easy = 1
    case medium = 2
    case hard = 3
    
    var displayText: String {
        switch self {
        case .easy:
            return "Kolay"
        case .medium:
            return "Orta"
        case .hard:
            return "Zor"
        }
    }
    
    var color: UIColor {
        switch self {
        case .easy:
            return .systemGreen
        case .medium:
            return .systemOrange
        case .hard:
            return .systemRed
        }
    }
}

struct Word: Codable, Identifiable {
    let id: String
    let word: String
    let meaning: String
    let example: String?
    let difficulty: Difficulty
    let box: Int
    let lastReviewedAt: Date
    let createdAt: Date
    
    var nextReviewDate: Date {
        let calendar = Calendar.current
        let reviewIntervals = [
            1,    // Box 1: Her gün
            2,    // Box 2: 2 günde bir
            4,    // Box 3: 4 günde bir
            7,    // Box 4: 7 günde bir
            14    // Box 5: 14 günde bir
        ]
        
        return calendar.date(byAdding: .day, value: reviewIntervals[box - 1], to: lastReviewedAt) ?? Date()
    }
    
    var needsReview: Bool {
        return Date() >= nextReviewDate
    }
    
    var daysUntilReview: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: nextReviewDate)
        return components.day ?? 0
    }
    
    var reviewStatus: ReviewStatus {
        if needsReview {
            return .due
        } else if daysUntilReview <= 1 {
            return .soon
        } else {
            return .upcoming
        }
    }
    
    init(id: String = UUID().uuidString,
         word: String,
         meaning: String,
         example: String? = nil,
         difficulty: Difficulty,
         box: Int = 1,
         lastReviewedAt: Date = Date(),
         createdAt: Date = Date()) {
        self.id = id
        self.word = word
        self.meaning = meaning
        self.example = example
        self.difficulty = difficulty
        self.box = box
        self.lastReviewedAt = lastReviewedAt
        self.createdAt = createdAt
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
            return "Tekrar Vakti"
        case .soon:
            return "Yakında"
        case .upcoming:
            return "Daha Sonra"
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
