//
//  EmployeeEndpoint.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

enum EmployeeEndpoint {
    static var getEmployees: Endpoint {
        Endpoint(path: "/employees", method: .get, queryItems: nil)
    }
}
