//
//  EmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation

protocol EmployeeRepository {

    func fetchAndSync(force: Bool) async throws

    func fetchPage(
        searchText: String?,
        department: String?,
        role: String?,
        isActiveOnly: Bool,
        paging: PagingRequest
    ) throws -> [Employee]

    func totalCount(
        searchText: String?,
        department: String?,
        role: String?,
        isActiveOnly: Bool
    ) throws -> Int

    func update(_ employee: Employee) throws
    func delete(_ employee: Employee) throws
}
