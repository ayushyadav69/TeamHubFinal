//
//  SwiftDataStack.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import SwiftData

final class SwiftDataStack {

    static let shared = SwiftDataStack()

    let container: ModelContainer

    private init() {
        do {
            let configuration = ModelConfiguration()

            container = try ModelContainer(
                for: TeamHubSchemaV1.concreteSchema,
                migrationPlan: TeamHubMigrationPlan.self,
                configurations: [configuration]
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
}

