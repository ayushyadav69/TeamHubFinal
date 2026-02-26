//
//  Filter.swift
//  TeamHub
//
//  Created by Ayush yadav on 16/02/26.
//

struct FilterSection: Hashable {
    let key: String        // stable identity (used in dictionary)
    let title: String      // display name
    let options: [String]
    let allowsMultiple: Bool
}
