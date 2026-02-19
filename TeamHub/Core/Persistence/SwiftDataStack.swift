//
//  SwiftDataStack.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import SwiftData
import Foundation

final class SwiftDataStack {

    static let shared = SwiftDataStack()

    let container: ModelContainer

    private init() {

        let configuration = ModelConfiguration()

        do {
            container = try ModelContainer(
                for: TeamHubSchemaV2.concreteSchema,
                configurations: [configuration]
            )
        }
        catch {
            // old incompatible store → delete & recreate
            Self.deleteStoreFiles()

            do {
                container = try ModelContainer(
                    for: TeamHubSchemaV2.concreteSchema,
                    configurations: [configuration]
                )
            } catch {
                fatalError("Failed to recreate ModelContainer: \(error)")
            }
        }
    }
}

private extension SwiftDataStack {

    static func deleteStoreFiles() {
        let url = URL.applicationSupportDirectory
            .appending(path: "default.store")

        try? FileManager.default.removeItem(at: url)
        try? FileManager.default.removeItem(at: url.appendingPathExtension("-wal"))
        try? FileManager.default.removeItem(at: url.appendingPathExtension("-shm"))
    }
}
