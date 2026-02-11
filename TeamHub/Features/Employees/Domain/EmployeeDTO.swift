//
//  EmployeeDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

struct EmployeeDTO: Decodable {
    let id: String
    let name: String
    let designation: String
    let department: String
    let isActive: Bool
    let imageURL: String
    let email: String
    let city: String
    let country: String
    let joiningDate: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case designation
        case department
        case isActive = "is_active"
        case imageURL = "img_url"
        case email
        case city
        case country
        case joiningDate = "joining_date"
    }
}

extension EmployeeDTO {
    
    func toDomain(dateParser: DateParsing) -> Employee {
        
        let parsedDate = dateParser.parse(joiningDate) ?? Date()
        
        return Employee(
            id: id,
            name: name,
            role: designation,
            department: department,
            isActive: isActive,
            imageURL: URL(string: imageURL),
            email: email,
            city: city,
            country: country,
            joiningDate: parsedDate
        )
    }
}

