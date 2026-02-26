//
//  Employee.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

struct Employee: Identifiable, Equatable, Hashable {

    let id: String
    let name: String
    let role: String
    let department: String
    let isActive: Bool
    let imageURL: URL?
    let email: String
    let city: String
    let country: String
    let joiningDate: Date
    
    
}

