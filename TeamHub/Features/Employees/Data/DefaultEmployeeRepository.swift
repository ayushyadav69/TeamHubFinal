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
        departments: Set<String>,
        roles: Set<String>,
        statuses: Set<EmployeeStatus>,
        paging: PagingRequest
    ) throws -> [Employee] {

        let search = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let deptArray = Array(departments)
        let roleArray = Array(roles)

        let wantsActive = statuses.contains(.active)
        let wantsInactive = statuses.contains(.inactive)
        let filterStatus = !statuses.isEmpty

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in

                // SEARCH
                (search == nil || entity.name.localizedStandardContains(search!))

                // DEPARTMENT (multi select)
                &&
                (deptArray.isEmpty || deptArray.contains(entity.department))

                // ROLE (multi select)
                &&
                (roleArray.isEmpty || roleArray.contains(entity.role))

                // STATUS
                &&
                (
                    !filterStatus
                    ||
                    (wantsActive && entity.isActive)
                    ||
                    (wantsInactive && !entity.isActive)
                )
            },
            sortBy: [SortDescriptor(\EmployeeEntity.name)]
        )

        var result = try context.fetch(descriptor)

        // Pagination manually (SwiftData offset is unstable in predicates)
        let start = paging.page * paging.pageSize
        let end = min(start + paging.pageSize, result.count)

        if start < end {
            result = Array(result[start..<end])
        } else {
            result = []
        }

        return result.map { (entity: EmployeeEntity) in
            entity.toDomain()
        }
    }




    func totalCount(
        searchText: String?,
        departments: Set<String>,
        roles: Set<String>,
        statuses: Set<EmployeeStatus>
    ) throws -> Int {

        let search = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)
        let deptArray = Array(departments)
        let roleArray = Array(roles)

        let wantsActive = statuses.contains(.active)
        let wantsInactive = statuses.contains(.inactive)
        let filterStatus = !statuses.isEmpty

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                (search == nil || entity.name.localizedStandardContains(search!))
                &&
                (deptArray.isEmpty || deptArray.contains(entity.department))
                &&
                (roleArray.isEmpty || roleArray.contains(entity.role))
                &&
                (
                    !filterStatus
                    ||
                    (wantsActive && entity.isActive)
                    ||
                    (wantsInactive && !entity.isActive)
                )
            }
        )

        return try context.fetchCount(descriptor)
    }




    func activeCount(
        searchText: String?,
        departments: Set<String>,
        roles: Set<String>
    ) throws -> Int {

        let search = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                entity.isActive
                &&
                (search == nil || entity.name.localizedStandardContains(search!))
                &&
                (departments.isEmpty || departments.contains(entity.department))
                &&
                (roles.isEmpty || roles.contains(entity.role))
            }
        )

        return try context.fetchCount(descriptor)
    }


    func inactiveCount(
        searchText: String?,
        departments: Set<String>,
        roles: Set<String>
    ) throws -> Int {

        let search = searchText?.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in
                !entity.isActive
                &&
                (search == nil || entity.name.localizedStandardContains(search!))
                &&
                (departments.isEmpty || departments.contains(entity.department))
                &&
                (roles.isEmpty || roles.contains(entity.role))
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
