//
//  TeamHubApp.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import SwiftUI
import SwiftData

@main
struct TeamHubApp: App {

    private let container: ModelContainer
    private let networkMonitor: NetworkMonitor
    private let repository: EmployeeRepository
    private let employeeListViewModel: EmployeeListViewModel

    init() {

        // SwiftData
        container = SwiftDataStack.shared.container

        // Network Monitor
        networkMonitor = NetworkMonitor.shared
        networkMonitor.start()

        // Networking Layer
        let networkService = URLSessionNetworkService()
        let decoder = JSONResponseDecoder()
        let apiClient = APIClient(
            networkService: networkService,
            decoder: decoder
        )

        // Utilities
        let dateParser = APIDateParser()
        let syncPolicy = DefaultSyncPolicy()

        // Repository
        repository = DefaultEmployeeRepository(
            apiClient: apiClient,
            container: container,
            dateParser: dateParser,
            syncPolicy: syncPolicy,
            networkMonitor: networkMonitor
        )

        // ViewModel
        employeeListViewModel = EmployeeListViewModel(
            repository: repository,
            networkMonitor: networkMonitor
        )

        // Background Sync
        BackgroundSyncManager.shared.register(repository: repository)
        BackgroundSyncManager.shared.schedule()
    }

    var body: some Scene {
        WindowGroup {
            EmployeeListView()
                .environment(employeeListViewModel)
                .environment(networkMonitor)
                .modelContainer(container)
        }
    }
}
