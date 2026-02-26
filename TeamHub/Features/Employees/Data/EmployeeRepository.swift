//
//  EmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

protocol EmployeeRepository {

    func fetchAndSync(force: Bool) async throws -> Bool
    
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

    func fetchDepartments() throws -> [String]
    func fetchRoles() throws -> [String]
}
