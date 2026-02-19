//
//  TeamHubSchemaV2.swift
//  TeamHub
//
//  Created by Ayush yadav on 19/02/26.
//

import Foundation
import SwiftData

enum TeamHubSchemaV2: VersionedSchema {

    static let versionIdentifier: Schema.Version = .init(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            EmployeeEntity.self,
            DepartmentEntity.self,
            RoleEntity.self
        ]
    }
}

extension TeamHubSchemaV2 {
    static var concreteSchema: Schema {
        Schema(versionedSchema: Self.self)
    }
}
