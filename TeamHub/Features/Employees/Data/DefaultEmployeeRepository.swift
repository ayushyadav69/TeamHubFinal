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

//    @MainActor
    func fetchAndSync(force: Bool) async throws -> Bool {

        guard networkMonitor.isConnected else {
            print("⚠️ No internet. Skipping sync.")
            return false
        }

        if !force && !syncPolicy.shouldSync() {
            return false
        }

        let response: EmployeeResponseDTO =
            try await apiClient.request(EmployeeEndpoint.getEmployees)

        let domainEmployees = response.data.employees.map {
            $0.toDomain(dateParser: dateParser)
        }

        let changed = try sync(domainEmployees)

        if changed {
            syncPolicy.markSynced()
        }

        return changed
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

        var descriptor = FetchDescriptor<EmployeeEntity>(
            predicate: #Predicate<EmployeeEntity> { entity in

                // SEARCH
                (search == nil || entity.name.localizedStandardContains(search!))

                // DEPARTMENT
                &&
                (deptArray.isEmpty || deptArray.contains(entity.departmentName))

                // ROLE
                &&
                (roleArray.isEmpty || roleArray.contains(entity.roleName))

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
            sortBy: [
                SortDescriptor(\EmployeeEntity.name),
                SortDescriptor(\EmployeeEntity.id) // important for stable paging
            ]
        )

        // 🔥 REAL DATABASE PAGINATION
        descriptor.fetchLimit = paging.pageSize
        descriptor.fetchOffset = paging.page * paging.pageSize

        let result = try context.fetch(descriptor)

        return result.map { $0.toDomain() }
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
                (deptArray.isEmpty || deptArray.contains(entity.departmentName))
                &&
                (roleArray.isEmpty || roleArray.contains(entity.roleName))
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
                (departments.isEmpty || departments.contains(entity.departmentName))
                &&
                (roles.isEmpty || roles.contains(entity.roleName))
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
                (departments.isEmpty || departments.contains(entity.departmentName))
                &&
                (roles.isEmpty || roles.contains(entity.roleName))
            }
        )

        return try context.fetchCount(descriptor)
    }


    // MARK: - Sync Logic

    private func sync(_ remoteEmployees: [Employee]) throws -> Bool {

        var didChange = false

        let descriptor = FetchDescriptor<EmployeeEntity>()
        let localEntities = try context.fetch(descriptor)

        var localDict = Dictionary(
            uniqueKeysWithValues: localEntities.map { ($0.id, $0) }
        )

        let remoteIDs = Set(remoteEmployees.map { $0.id })

        for employee in remoteEmployees {

            if let existing = localDict[employee.id] {

                // Ensure relations exist
                existing.department = try department(named: employee.department)
                existing.role = try role(named: employee.role)

                // Update only if needed
                if hasChanges(existing, comparedTo: employee) {
                    try applyChanges(from: employee, to: existing)
                    didChange = true
                }

                localDict.removeValue(forKey: employee.id)

            } else {

                let newEntity = EmployeeEntity.fromDomain(employee)
                newEntity.department = try department(named: employee.department)
                newEntity.role = try role(named: employee.role)
                context.insert(newEntity)

                didChange = true
            }
        }

        // deletions
        for remaining in localDict.values {
            if !remoteIDs.contains(remaining.id) {
                context.delete(remaining)
                didChange = true
            }
        }

        if didChange {
            try context.save()
        }

        return didChange
    }

    // MARK: - Helpers

    private func hasChanges(_ entity: EmployeeEntity, comparedTo employee: Employee) -> Bool {

        entity.name != employee.name ||
        entity.roleName != employee.role ||
        entity.departmentName != employee.department ||
        entity.isActive != employee.isActive ||
        entity.imageURL != employee.imageURL?.absoluteString ||
        entity.email != employee.email ||
        entity.city != employee.city ||
        entity.country != employee.country ||
        entity.joiningDate != employee.joiningDate
    }

    private func applyChanges(from employee: Employee, to entity: EmployeeEntity) throws {

        entity.name = employee.name
        entity.roleName = employee.role
        entity.departmentName = employee.department
        entity.isActive = employee.isActive
        entity.imageURL = employee.imageURL?.absoluteString ?? ""
        entity.email = employee.email
        entity.city = employee.city
        entity.country = employee.country
        entity.joiningDate = employee.joiningDate

        // IMPORTANT: ensure metadata tables always populated
        entity.department = try department(named: employee.department)
        entity.role = try role(named: employee.role)
    }

    
    // MARK: - Dynamic Filter Metadata

    func fetchDepartments() throws -> [String] {

        let descriptor = FetchDescriptor<DepartmentEntity>(
            sortBy: [SortDescriptor(\.name)]
        )

        return try context.fetch(descriptor).map(\.name)

    }

    func fetchRoles() throws -> [String] {

        let descriptor = FetchDescriptor<RoleEntity>(
            sortBy: [SortDescriptor(\.name)]
        )

        return try context.fetch(descriptor).map(\.name)

    }
    
    private func department(named name: String) throws -> DepartmentEntity {

        let descriptor = FetchDescriptor<DepartmentEntity>(
            predicate: #Predicate { $0.name == name }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let new = DepartmentEntity(name: name)
        context.insert(new)
        return new
    }

    private func role(named name: String) throws -> RoleEntity {

        let descriptor = FetchDescriptor<RoleEntity>(
            predicate: #Predicate { $0.name == name }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let new = RoleEntity(name: name)
        context.insert(new)
        return new
    }


}
