//
//  EmployeeResponseDTO.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

struct EmployeeResponseDTO: Decodable {
    let status: String
    let message: String
    let data: EmployeeDataDTO
}

struct EmployeeDataDTO: Decodable {
    let employees: [EmployeeDTO]
}
