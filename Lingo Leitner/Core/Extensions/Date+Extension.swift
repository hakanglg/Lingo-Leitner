//
//  Date+Extension.swift
//  Lingo Leitner
//
//  Created by Hakan Gölge on 10.01.2025.
//

import Foundation


extension Date {
    // Gün
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    // Ay
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    // Yıl
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    static func fromString(_ dateString: String, format: String = "dd MM yyyy") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC") // Firestore tarihleri UTC olabilir
        formatter.locale = Locale(identifier: "en_US_POSIX") // Daha kesin çözüm için POSIX kullan
        return formatter.date(from: dateString)
    }
    
    // Formatlanmış tarih stringi al
    func formattedDate(format: String = "dd MM yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}
