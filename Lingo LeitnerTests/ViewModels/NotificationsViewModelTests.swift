import XCTest
@testable import Lingo_Leitner

final class NotificationsViewModelTests: XCTestCase {
    var sut: NotificationsViewModel!
    var mockFirestoreService: MockFirestoreService!
    var mockAuthManager: MockAuthManager!
    var mockDelegate: MockNotificationsViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        mockFirestoreService = MockFirestoreService()
        mockAuthManager = MockAuthManager()
        mockDelegate = MockNotificationsViewModelDelegate()
        sut = NotificationsViewModel(
            firestoreService: mockFirestoreService,
            authManager: mockAuthManager
        )
        sut.delegate = mockDelegate
    }
    
    override func tearDown() {
        sut = nil
        mockFirestoreService = nil
        mockAuthManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func test_fetchNotifications_whenUserNotFound_callsDelegateWithError() async {
        // Given
        mockAuthManager.currentUser = nil
        
        // When
        await sut.fetchNotifications()
        
        // Then
        XCTAssertTrue(mockDelegate.didReceiveErrorCalled)
        XCTAssertTrue(mockDelegate.lastError is AuthError)
    }
    
    func test_fetchNotifications_whenServiceSucceeds_updatesDueWords() async {
        // Given
        mockAuthManager.currentUser = User(id: "test-user", email: "test@test.com")
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let dueWord = Word(
            id: "test-id",
            word: "test",
            meaning: "test anlamı",
            example: nil,
            difficulty: .easy,
            box: 1,
            nextReviewDate: pastDate,
            lastReviewedAt: pastDate
        )
        mockFirestoreService.mockWords = [dueWord]
        
        // When
        await sut.fetchNotifications()
        
        // Then
        XCTAssertTrue(mockDelegate.didStartLoadingCalled)
        XCTAssertTrue(mockDelegate.didFinishLoadingCalled)
        XCTAssertEqual(sut.dueWords.count, 1)
        XCTAssertEqual(sut.dueWords.first?.id, dueWord.id)
    }
}

// MARK: - Mocks
private final class MockFirestoreService: FirestoreServiceProtocol {
    var mockWords: [Word] = []
    
    func getWordsInBox(box: Int, userId: String) async throws -> [Word] {
        return mockWords
    }
    
    // Implement other protocol methods...
}

private final class MockAuthManager {
    var currentUser: User?
}

private final class MockNotificationsViewModelDelegate: NotificationsViewModelDelegate {
    var didStartLoadingCalled = false
    var didFinishLoadingCalled = false
    var didReceiveErrorCalled = false
    var lastError: Error?
    
    func didStartLoading() {
        didStartLoadingCalled = true
    }
    
    func didFinishLoading() {
        didFinishLoadingCalled = true
    }
    
    func didReceiveError(_ error: Error) {
        didReceiveErrorCalled = true
        lastError = error
    }
} 