//
//  AppDIContainer.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftData

@MainActor
final class AppDIContainer {

    let modelContainer: ModelContainer

    private let networkMonitor: NetworkMonitor
    private let apiClient: APIClient
    private let dateParser: DateParsing
    private let syncPolicy: SyncPolicy

    let employeeRepository: EmployeeRepository
    let employeeListViewModel: EmployeeListViewModel

    init() {

        modelContainer = SwiftDataStack.shared.container

        networkMonitor = NetworkMonitor.shared
        networkMonitor.start()

        let networkService = URLSessionNetworkService()
        let decoder = JSONResponseDecoder()

        apiClient = APIClient(networkService: networkService, decoder: decoder)

        dateParser = APIDateParser()
        syncPolicy = DefaultSyncPolicy()

        employeeRepository = DefaultEmployeeRepository(
            apiClient: apiClient,
            container: modelContainer,
            dateParser: dateParser,
            syncPolicy: syncPolicy,
            networkMonitor: networkMonitor
        )

        employeeListViewModel = EmployeeListViewModel(repository: employeeRepository, networkMonitor: networkMonitor)

        BackgroundSyncManager.shared.register(repository: employeeRepository)
        BackgroundSyncManager.shared.schedule()
    }
}
