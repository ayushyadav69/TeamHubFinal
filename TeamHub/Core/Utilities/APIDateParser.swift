//
//  APIDateParser.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

struct APIDateParser: DateParsing {
    
    private let formatter: DateFormatter
    
    init(formatter: DateFormatter = .apiDateFormatter) {
        self.formatter = formatter
    }
    
    func parse(_ string: String) -> Date? {
        formatter.date(from: string)
    }
    
    
}
