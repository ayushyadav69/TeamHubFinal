//
//  TeamHubSchemaV1.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import SwiftData

enum TeamHubSchemaV1: VersionedSchema {

    static let versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            EmployeeEntity.self
        ]
    }
}

extension TeamHubSchemaV1 {
    static var concreteSchema: Schema {
        Schema(versionedSchema: Self.self)
    }
}
