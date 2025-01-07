import XCTest
@testable import Lingo_Leitner

final class WordTests: XCTestCase {
    func test_needsReview_whenDateIsPast_returnsTrue() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let word = Word(
            id: "test-id",
            word: "test",
            meaning: "test anlamı",
            example: nil,
            difficulty: .easy,
            box: 1,
            nextReviewDate: pastDate,
            lastReviewedAt: pastDate
        )
        
        // When
        let needsReview = word.needsReview
        
        // Then
        XCTAssertTrue(needsReview)
    }
    
    func test_needsReview_whenDateIsFuture_returnsFalse() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let word = Word(
            id: "test-id",
            word: "test",
            meaning: "test anlamı",
            example: nil,
            difficulty: .easy,
            box: 1,
            nextReviewDate: futureDate,
            lastReviewedAt: Date()
        )
        
        // When
        let needsReview = word.needsReview
        
        // Then
        XCTAssertFalse(needsReview)
    }
    
    func test_reviewStatus_whenNeedsReview_returnsDue() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let word = Word(
            id: "test-id",
            word: "test",
            meaning: "test anlamı",
            example: nil,
            difficulty: .easy,
            box: 1,
            nextReviewDate: pastDate,
            lastReviewedAt: pastDate
        )
        
        // When
        let status = word.reviewStatus
        
        // Then
        XCTAssertEqual(status, .due)
    }
    
    func test_reviewStatus_whenOneDayLeft_returnsSoon() {
        // Given
        let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let word = Word(
            id: "test-id",
            word: "test",
            meaning: "test anlamı",
            example: nil,
            difficulty: .easy,
            box: 1,
            nextReviewDate: tomorrowDate,
            lastReviewedAt: Date()
        )
        
        // When
        let status = word.reviewStatus
        
        // Then
        XCTAssertEqual(status, .soon)
    }
    
    func test_reviewStatus_whenMoreThanOneDayLeft_returnsUpcoming() {
        // Given
        let futureDateDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let word = Word(
            id: "test-id",
            word: "test",
            meaning: "test anlamı",
            example: nil,
            difficulty: .easy,
            box: 1,
            nextReviewDate: futureDateDate,
            lastReviewedAt: Date()
        )
        
        // When
        let status = word.reviewStatus
        
        // Then
        XCTAssertEqual(status, .upcoming)
    }
} 