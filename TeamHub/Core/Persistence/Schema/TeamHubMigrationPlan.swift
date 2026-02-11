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
            TeamHubSchemaV1.self
        ]
    }

    static var stages: [MigrationStage] {
        []
    }
}

