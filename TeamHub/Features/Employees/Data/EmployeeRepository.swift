//
//  EmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

protocol EmployeeRepository {

    func fetchAndSync(force: Bool) async throws -> Bool
    
//    func employee(by id: String) throws -> Employee?

    // 🔥 MULTI FILTER
    func fetchPage(
        searchText: String?,
        departments: Set<String>,
        roles: Set<String>,
        statuses: Set<EmployeeStatus>,
        paging: PagingRequest
    ) throws -> [Employee]

    func totalCount(
        searchText: String?,
        departments: Set<String>,
        roles: Set<String>,
        statuses: Set<EmployeeStatus>
    ) throws -> Int

    func activeCount(
        searchText: String?,
        departments: Set<String>,
        roles: Set<String>
    ) throws -> Int

    func inactiveCount(
        searchText: String?,
        departments: Set<String>,
        roles: Set<String>
    ) throws -> Int

//    func update(_ employee: Employee) throws
//    func delete(_ employee: Employee) throws
    func fetchDepartments() throws -> [String]
    func fetchRoles() throws -> [String]
}
