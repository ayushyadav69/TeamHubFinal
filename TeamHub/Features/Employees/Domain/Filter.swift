//
//  Filter.swift
//  TeamHub
//
//  Created by Ayush yadav on 16/02/26.
//

//enum FilterKind: Hashable {
//    case multiSelect(options: [String])
//    case status // special tri-state
//}
//
//struct FilterSection: Hashable {
//    let title: String
//    let kind: FilterKind
//}

struct FilterSection: Hashable {
    let key: String        // stable identity (used in dictionary)
    let title: String      // display name
    let options: [String]
    let allowsMultiple: Bool
}
