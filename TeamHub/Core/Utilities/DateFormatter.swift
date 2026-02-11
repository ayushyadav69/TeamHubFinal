//
//  DateFormatter.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

extension DateFormatter {

    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
