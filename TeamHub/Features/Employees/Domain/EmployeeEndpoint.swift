//
//  EmployeeEndpoint.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

enum EmployeeEndpoint {

    static func getEmployees(limit: Int, offset: Int) -> Endpoint {

        Endpoint(
            path: "/employees",
            method: .get,
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "offset", value: "\(offset)")
            ]
        )
    }
}
