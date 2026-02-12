//
//  EmployeeDetailViewModel.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployeeDetailViewModel {

    private let repository: EmployeeRepository
    private let employeeID: String

    var employee: Employee?
    var isLoading = false
    var error: String?

    init(employeeID: String, repository: EmployeeRepository) {
        self.employeeID = employeeID
        self.repository = repository
    }

    func load() async {
        if employee != nil { return }

        isLoading = true
        defer { isLoading = false }

        do {
            // repository already has DB cache → NO network hit required
            employee = try repository.employee(by: employeeID)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
