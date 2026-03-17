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
    private let pageKey = "EmployeeListCurrentPage"
    
    // MARK: - UI State
    
    var employees: [Employee] = []
    var hasLoadedFromDB = false
    
    var searchText: String = "" {
        didSet {
            if searchText == oldValue { return }
            resetAndReload()
        }
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
    
    // DB-Level Counts (not page-level)
    var totalCount: Int = 0
    var activeCount: Int = 0
    var inactiveCount: Int = 0
    
    var departments: [String] = []
    var roles: [String] = []
    
    var isLoading = false
    var isSyncing = false
    var appError: AppError?
    var isOffline = false
    var isInitialLoading : Bool = true
    
    // MARK: - Paging
    
    private var currentPage = 0
    private let pageSize = 10
    var canLoadMore = true
    
    // MARK: - Init
    
    init(
        repository: EmployeeRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.repository = repository
        self.networkMonitor = networkMonitor
        
        // restore saved page
//           currentPage = UserDefaults.standard.integer(forKey: pageKey)
        
        observeConnectivity()
    }
    
    // MARK: - Connectivity
    
    private func observeConnectivity() {
        
        Task {
            for await connected in networkMonitor.connectionStream {
                
                let wasOffline = isOffline
                await MainActor.run { isOffline = !connected }
                
                guard wasOffline && connected else { continue }
                
                let changed = await syncIfNeeded()
                
                if changed {
                    await loadInitialPage()
                    await loadFilters()
                    loadCounts()
                }
            }
        }
    }
    
    // MARK: - Initial Load
    
    func initialLoad() async {
        
        isInitialLoading = true
        defer { isInitialLoading = false }
        
        if !employees.isEmpty { return }
        // show cached DB immediately
        await loadInitialPage()
        await loadFilters()
        loadCounts()
        
        // sync silently after UI appears
        let changed = await syncIfNeeded()
        
        if changed {
            await loadInitialPage()
            await loadFilters()
            loadCounts()
        }
        
    }
    
    func syncIfNeeded() async -> Bool {
        
        if isSyncing { return false }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            return try await repository.fetchAndSync(force: false)
        } catch is CancellationError {
            return false   // ignore silently
        } catch {
            appError = AppError(message: error.localizedDescription)
            return false
        }
    }
    
    // MARK: - Paging
    
    func loadInitialPage() async {
        
        currentPage = 0
        UserDefaults.standard.set(currentPage, forKey: pageKey)
        canLoadMore = true
        employees.removeAll()
        await loadNextPage()
        
        hasLoadedFromDB = true
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

            var newEmployees = try repository.fetchPage(
                searchText: searchText.isEmpty ? nil : searchText,
                departments: selectedDepartments,
                roles: selectedRoles,
                statuses: selectedStatuses,
                paging: paging
            )

            // If DB has nothing, try API
            if newEmployees.isEmpty && networkMonitor.isConnected {

                let apiEmployees = try await repository.fetchPageFromAPI(paging: paging)

                if apiEmployees.count < pageSize {
                    canLoadMore = false
                }

                newEmployees = try repository.fetchPage(
                    searchText: searchText.isEmpty ? nil : searchText,
                    departments: selectedDepartments,
                    roles: selectedRoles,
                    statuses: selectedStatuses,
                    paging: paging
                )
            }

            // If still empty → no more data
            if newEmployees.isEmpty {
                canLoadMore = false
                return
            }

//            let existingIDs = Set(employees.map(\.id))
//            let uniqueEmployees = newEmployees.filter { !existingIDs.contains($0.id) }

            employees.append(contentsOf: newEmployees)

            // Page consumed
            currentPage += 1
            UserDefaults.standard.set(currentPage, forKey: pageKey)

            await loadFilters()
            loadCounts()

        } catch is CancellationError {
            // ignore silently
        } catch {
            appError = AppError(message: error.localizedDescription)
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
            appError = AppError(message: error.localizedDescription)
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
            appError = AppError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Manual Refresh
    
    func refresh() async {
        
        if isSyncing { return }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let changed = try await repository.fetchAndSync(force: true)
            
            if changed {
                await loadInitialPage()
                await loadFilters()
                loadCounts()
            }
            
        }catch is CancellationError {
            // ignore silently
        } catch {
            appError = AppError(message: error.localizedDescription)
        }
    }
}
