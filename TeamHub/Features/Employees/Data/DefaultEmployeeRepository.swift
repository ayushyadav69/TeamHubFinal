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
    private let syncPolicy: SyncPolicy
    private let networkMonitor: NetworkMonitor

    init(
        apiClient: APIClient,
        container: ModelContainer,
        dateParser: DateParsing,
        syncPolicy: SyncPolicy,
        networkMonitor: NetworkMonitor = .shared
    ) {
        self.apiClient = apiClient
        self.context = ModelContext(container)
        self.dateParser = dateParser
        self.syncPolicy = syncPolicy
        self.networkMonitor = networkMonitor
    }

    // MARK: - Sync

    @MainActor
    func fetchAndSync(force: Bool) async throws {

        guard networkMonitor.isConnected else {
            print("⚠️ No internet. Skipping sync.")
            return
        }

        if !force && !syncPolicy.shouldSync() {
            return
        }

        let response: EmployeeResponseDTO =
            try await apiClient.request(EmployeeEndpoint.getEmployees)

        let domainEmployees = response.data.employees.map {
            $0.toDomain(dateParser: dateParser)
        }

        try sync(domainEmployees)

        syncPolicy.markSynced()
    }



    // MARK: - Paging + Filtering

    func fetchPage(
        searchText: String?,
        department: String?,
        role: String?,
        isActiveOnly: Bool,
        paging: PagingRequest
    ) throws -> [Employee] {

        let search = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let dept = department
        let r = role
        let activeOnly = isActiveOnly

        var descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                (search == nil || entity.name.localizedStandardContains(search!)) &&
                (dept == nil || entity.department == dept!) &&
                (r == nil || entity.role == r!) &&
                (!activeOnly || entity.isActive == true)
            },
            sortBy: [SortDescriptor(\.name)]
        )

        descriptor.fetchLimit = paging.pageSize
        descriptor.fetchOffset = paging.offset

        let entities = try context.fetch(descriptor)

        return entities.map { $0.toDomain() }
    }

    func totalCount(
        searchText: String?,
        department: String?,
        role: String?,
        isActiveOnly: Bool
    ) throws -> Int {

        let search = searchText
        let dept = department
        let r = role
        let activeOnly = isActiveOnly

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                (search == nil || entity.name.localizedStandardContains(search!)) &&
                (dept == nil || entity.department == dept!) &&
                (r == nil || entity.role == r!) &&
                (!activeOnly || entity.isActive == true)
            }
        )

        return try context.fetchCount(descriptor)
    }

    func activeCount(
        searchText: String?,
        department: String?,
        role: String?
    ) throws -> Int {

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                (searchText == nil || entity.name.localizedStandardContains(searchText!)) &&
                (department == nil || entity.department == department!) &&
                (role == nil || entity.role == role!) &&
                entity.isActive == true
            }
        )

        return try context.fetchCount(descriptor)
    }

    func inactiveCount(
        searchText: String?,
        department: String?,
        role: String?
    ) throws -> Int {

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                (searchText == nil || entity.name.localizedStandardContains(searchText!)) &&
                (department == nil || entity.department == department!) &&
                (role == nil || entity.role == role!) &&
                entity.isActive == false
            }
        )

        return try context.fetchCount(descriptor)
    }

    // MARK: - Update / Delete

    func update(_ employee: Employee) throws {

        let id = employee.id

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

        let id = employee.id

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                entity.id == id
            }
        )

        guard let entity = try context.fetch(descriptor).first else { return }

        context.delete(entity)
        try context.save()
    }

    // MARK: - Sync Logic

    private func sync(_ remoteEmployees: [Employee]) throws {

        let descriptor = FetchDescriptor<EmployeeEntity>()
        let localEntities = try context.fetch(descriptor)

        var localDict = Dictionary(
            uniqueKeysWithValues: localEntities.map { ($0.id, $0) }
        )

        let remoteIDs = Set(remoteEmployees.map { $0.id })

        for employee in remoteEmployees {

            if let existing = localDict[employee.id] {

                if hasChanges(existing, comparedTo: employee) {
                    applyChanges(from: employee, to: existing)
                }

                localDict.removeValue(forKey: employee.id)

            } else {

                let newEntity = EmployeeEntity.fromDomain(employee)
                context.insert(newEntity)
            }
        }

        for remaining in localDict.values {
            if !remoteIDs.contains(remaining.id) {
                context.delete(remaining)
            }
        }

        try context.save()
    }

    // MARK: - Helpers

    private func hasChanges(_ entity: EmployeeEntity, comparedTo employee: Employee) -> Bool {

        entity.name != employee.name ||
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

        entity.name = employee.name
        entity.role = employee.role
        entity.department = employee.department
        entity.isActive = employee.isActive
        entity.imageURL = employee.imageURL?.absoluteString ?? ""
        entity.email = employee.email
        entity.city = employee.city
        entity.country = employee.country
        entity.joiningDate = employee.joiningDate
    }
    
    // MARK: - Dynamic Filter Metadata

    func fetchDepartments() throws -> [String] {

        let descriptor = FetchDescriptor<EmployeeEntity>(
            sortBy: [SortDescriptor(\.department)]
        )

        let entities = try context.fetch(descriptor)

        let departments = Set(entities.map { $0.department })

        return Array(departments).sorted()
    }

    func fetchRoles() throws -> [String] {

        let descriptor = FetchDescriptor<EmployeeEntity>(
            sortBy: [SortDescriptor(\.role)]
        )

        let entities = try context.fetch(descriptor)

        let roles = Set(entities.map { $0.role })

        return Array(roles).sorted()
    }
    
    func employee(by id: String) throws -> Employee? {

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { $0.id == id }
        )

        return try context.fetch(descriptor).first?.toDomain()
    }


}
