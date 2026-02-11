//
//  EmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

protocol EmployeeRepository {

    func fetchAndSync() async throws

    func fetchFromDatabase() throws -> [Employee]

    func update(_ employee: Employee) throws

    func delete(_ employee: Employee) throws
}
