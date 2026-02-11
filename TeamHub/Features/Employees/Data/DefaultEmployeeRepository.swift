//
//  DefaultEmployeeRepository.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation
import SwiftData

final class DefaultEmployeeRepository: EmployeeRepository {

    // MARK: - Dependencies

    private let apiClient: APIClient
    private let context: ModelContext
    private let dateParser: DateParsing

    // MARK: - Init

    init(
        apiClient: APIClient,
        container: ModelContainer,
        dateParser: DateParsing
    ) {
        self.apiClient = apiClient
        self.context = ModelContext(container)
        self.dateParser = dateParser
    }

    // MARK: - Public API

    func fetchAndSync() async throws {

        let response: EmployeeResponseDTO =
            try await apiClient.request(EmployeeEndpoint.getEmployees)

        let domainEmployees = response.data.employees.map {
            $0.toDomain(dateParser: dateParser)
        }

        try sync(domainEmployees)
    }

    func fetchFromDatabase() throws -> [Employee] {

        let descriptor = FetchDescriptor<EmployeeEntity>()
        let entities = try context.fetch(descriptor)

        return entities.map { $0.toDomain() }
    }

    func update(_ employee: Employee) throws {

        let id = employee.id  // Freeze for predicate

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                entity.id == id
            }
        )

        guard let entity = try context.fetch(descriptor).first else { return }

        applyChanges(from: employee, to: entity)

        try context.save()
    }

    func delete(_ employee: Employee) throws {

        let id = employee.id  // Freeze for predicate

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                entity.id == id
            }
        )

        guard let entity = try context.fetch(descriptor).first else { return }

        context.delete(entity)

        try context.save()
    }

    // MARK: - Private Sync Logic

    private func sync(_ remoteEmployees: [Employee]) throws {

        let descriptor = FetchDescriptor<EmployeeEntity>()
        let localEntities = try context.fetch(descriptor)

        var localDictionary = Dictionary(
            uniqueKeysWithValues: localEntities.map { ($0.id, $0) }
        )

        let remoteIDs = Set(remoteEmployees.map { $0.id })

        // Insert or Update
        for employee in remoteEmployees {

            if let existing = localDictionary[employee.id] {

                if hasChanges(existing, comparedTo: employee) {
                    applyChanges(from: employee, to: existing)
                }

                localDictionary.removeValue(forKey: employee.id)

            } else {

                let newEntity = EmployeeEntity.fromDomain(employee)
                context.insert(newEntity)
            }
        }

        // Delete removed employees
        for remaining in localDictionary.values {
            if !remoteIDs.contains(remaining.id) {
                context.delete(remaining)
            }
        }

        try context.save()
    }

    // MARK: - Helpers

    private func hasChanges(_ entity: EmployeeEntity, comparedTo employee: Employee) -> Bool {

        return entity.name != employee.name ||
               entity.role != employee.role ||
               entity.department != employee.department ||
               entity.isActive != employee.isActive ||
               entity.imageURL != employee.imageURL?.absoluteString ||
               entity.email != employee.email ||
               entity.city != employee.city ||
               entity.country != employee.country ||
               entity.joiningDate != employee.joiningDate
    }

    private func applyChanges(from employee: Employee, to entity: EmployeeEntity) {

        // IMPORTANT: ID is immutable and never modified

        entity.name = employee.name
        entity.role = employee.role
        entity.department = employee.department
        entity.isActive = employee.isActive
        entity.imageURL = employee.imageURL?.absoluteString ?? ""
        entity.email = employee.email
        entity.city = employee.city
        entity.country = employee.country
        entity.joiningDate = employee.joiningDate

        // Future-ready:
        // entity.isFavorite = employee.isFavorite
        // entity.isExcellentPerformer = employee.isExcellentPerformer
    }
}
