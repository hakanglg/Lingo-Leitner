import Foundation

enum Constants {
    static let dailyWordLimit = 10
    static let dailyWordLimitKey = "daily_word_count"
    static let lastWordAddDateKey = "last_word_add_date"
}

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}
