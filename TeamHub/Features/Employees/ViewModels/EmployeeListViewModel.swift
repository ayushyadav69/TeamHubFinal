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

    var searchText: String = "" {
        didSet { resetAndReload() }
    }

    var selectedDepartments: Set<String> = [] {
        didSet { resetAndReload() }
    }

    var selectedRoles: Set<String> = [] {
        didSet { resetAndReload() }
    }

    var selectedStatuses: Set<EmployeeStatus> = [] {
        didSet { resetAndReload() }
    }

    // 🔥 DB-Level Counts (not page-level)
    var totalCount: Int = 0
    var activeCount: Int = 0
    var inactiveCount: Int = 0

    var departments: [String] = []
    var roles: [String] = []

    var isLoading = false
    var errorMessage: String?
    var isOffline = false

    // MARK: - Paging

    private var currentPage = 0
    private let pageSize = 20
    var canLoadMore = true

    // MARK: - Init

    init(
        repository: EmployeeRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.repository = repository
        self.networkMonitor = networkMonitor
        observeConnectivity()
    }

    // MARK: - Connectivity

    private func observeConnectivity() {

        isOffline = !networkMonitor.isConnected

        Task {
            while true {
                try? await Task.sleep(nanoseconds: 500_000_000)

                let connected = networkMonitor.isConnected

                if isOffline && connected {
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
        await loadFilters()
        loadCounts()
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

        do {
            let paging = PagingRequest(
                page: currentPage,
                pageSize: pageSize
            )

            let newEmployees = try repository.fetchPage(
                searchText: searchText.isEmpty ? nil : searchText,
                departments: selectedDepartments,
                roles: selectedRoles,
                statuses: selectedStatuses,
                paging: paging
            )


            employees.append(contentsOf: newEmployees)

            if newEmployees.count < pageSize {
                canLoadMore = false
            } else {
                currentPage += 1
            }

            // 🔥 Always refresh counts from DB
            loadCounts()

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMoreIfNeeded(current employee: Employee) {
        guard canLoadMore else { return }
        guard let last = employees.last else { return }

        if last.id == employee.id {
            Task {
                await loadNextPage()
            }
        }
    }

    private func resetAndReload() {
        Task {
            await loadInitialPage()
            loadCounts()
        }
    }

    // MARK: - Filters

    func loadFilters() async {
        do {
            departments = try repository.fetchDepartments()
            roles = try repository.fetchRoles()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - DB-Level Counts

    private func loadCounts() {

        do {
            totalCount = try repository.totalCount(
                searchText: searchText.isEmpty ? nil : searchText,
                departments: selectedDepartments,
                roles: selectedRoles,
                statuses: selectedStatuses
            )

            activeCount = try repository.activeCount(
                searchText: searchText.isEmpty ? nil : searchText,
                departments: selectedDepartments,
                roles: selectedRoles
            )

            inactiveCount = try repository.inactiveCount(
                searchText: searchText.isEmpty ? nil : searchText,
                departments: selectedDepartments,
                roles: selectedRoles
            )


        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Manual Refresh

    func refresh() async {
        do {
            try await repository.fetchAndSync(force: true)
            await loadInitialPage()
            await loadFilters()
            loadCounts()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
