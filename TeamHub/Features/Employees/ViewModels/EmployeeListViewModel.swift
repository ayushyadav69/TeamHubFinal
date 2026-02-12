//
//  EmployeeListViewModel.swift
//  TeamHub
//
//  Created by Ayush yadav on 11/02/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class EmployeeListViewModel {

    // MARK: - Dependencies

    private let repository: EmployeeRepository
    private let networkMonitor: NetworkMonitor

    // MARK: - UI State

    var employees: [Employee] = []
    var isLoading = false
    var errorMessage: String?
    var isOffline = false

    // Filters
    var searchText: String?
    var selectedDepartment: String?
    var selectedRole: String?
    var isActiveOnly: Bool = false {
        didSet { resetAndReload() }
    }

    // Paging
    private var currentPage = 0
    private let pageSize = 20
    private var canLoadMore = true

    // MARK: - Init

    init(
        repository: EmployeeRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.repository = repository
        self.networkMonitor = networkMonitor

        observeConnectivity()
    }

    // MARK: - Connectivity Reaction

    private func observeConnectivity() {

        // Initial state
        isOffline = !networkMonitor.isConnected

        // Reactive through Observation system
        _ = networkMonitor.isConnected

        Task {
            while true {
                try? await Task.sleep(nanoseconds: 500_000_000)

                let connected = networkMonitor.isConnected

                if isOffline && connected {
                    print("🌐 Internet restored → syncing")
                    await syncIfNeeded()
                }

                isOffline = !connected
            }
        }
    }

    // MARK: - Initial Load

    func initialLoad() async {
        await syncIfNeeded()
        await loadInitialPage()
    }

    private func syncIfNeeded() async {
        do {
            try await repository.fetchAndSync(force: false)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Paging

    func loadInitialPage() async {
        currentPage = 0
        canLoadMore = true
        employees.removeAll()
        await loadNextPage()
    }

    func loadNextPage() async {

        guard !isLoading, canLoadMore else { return }

        isLoading = true

        defer { isLoading = false }

        let request = PagingRequest(
            page: currentPage,
            pageSize: pageSize
        )

        do {
            let page = try repository.fetchPage(
                searchText: searchText,
                department: selectedDepartment,
                role: selectedRole,
                isActiveOnly: isActiveOnly,
                paging: request
            )

            if page.count < pageSize {
                canLoadMore = false
            }

            employees.append(contentsOf: page)
            currentPage += 1

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Filters

    func resetAndReload() {
        Task {
            await loadInitialPage()
        }
    }
}
