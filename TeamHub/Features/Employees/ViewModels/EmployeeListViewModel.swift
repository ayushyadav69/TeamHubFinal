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
    
    // 🔥 DB-Level Counts (not page-level)
    var totalCount: Int = 0
    var activeCount: Int = 0
    var inactiveCount: Int = 0
    
    var departments: [String] = []
    var roles: [String] = []
    
    var isLoading = false
    var isSyncing = false
    var errorMessage: String?
    var isOffline = false
    var isInitialLoading = true
    
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
        
        errorMessage = nil
        isInitialLoading = true
        
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
        isInitialLoading = false
    }
    
    func syncIfNeeded() async -> Bool {
        
        if isSyncing { return false }
        
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            return try await repository.fetchAndSync(force: false)
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Paging
    
    func loadInitialPage() async {
        currentPage = 0
        canLoadMore = true
        employees.removeAll()
        await loadNextPage()
        
        // allow first frame to render shimmer
        await Task.yield()
        
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
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
