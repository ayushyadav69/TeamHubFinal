//
//  TeamHubMigrationPlan.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import SwiftData

enum TeamHubMigrationPlan: SchemaMigrationPlan {

    static var schemas: [any VersionedSchema.Type] {
        [
            TeamHubSchemaV1.self,
            TeamHubSchemaV2.self
        ]
    }

    static var stages: [MigrationStage] {
        [
            migrateV1toV2
        ]
    }
}

extension TeamHubMigrationPlan {

    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: TeamHubSchemaV1.self,
        toVersion: TeamHubSchemaV2.self,
        willMigrate: { context in

            let employees = try context.fetch(FetchDescriptor<EmployeeEntity>())

            var departmentCache: [String: DepartmentEntity] = [:]
            var roleCache: [String: RoleEntity] = [:]

            for employee in employees {

                // Department
                let deptName = employee.departmentName
                let department: DepartmentEntity

                if let cached = departmentCache[deptName] {
                    department = cached
                } else {
                    let newDept = DepartmentEntity(name: deptName)
                    context.insert(newDept)
                    departmentCache[deptName] = newDept
                    department = newDept
                }

                // Role
                let roleName = employee.roleName
                let role: RoleEntity

                if let cached = roleCache[roleName] {
                    role = cached
                } else {
                    let newRole = RoleEntity(name: roleName)
                    context.insert(newRole)
                    roleCache[roleName] = newRole
                    role = newRole
                }

                // Attach relationships
                employee.department = department
                employee.role = role
            }
        },
        didMigrate: nil
    )
}
