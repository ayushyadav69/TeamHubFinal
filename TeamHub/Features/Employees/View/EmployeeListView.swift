//
//  EmployeeListView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct EmployeeListView: View {

    @Environment(EmployeeListViewModel.self) private var viewModel
    @Environment(AppCoordinator.self) private var coordinator

    @State private var showFilters = false
    @State private var isRefreshing = false
//    @State private var scrollPos: String?
//    @FocusState private var searchFocused: Bool

    private var hasActiveFilters: Bool {
        !viewModel.selectedDepartments.isEmpty ||
        !viewModel.selectedRoles.isEmpty ||
        !viewModel.selectedStatuses.isEmpty
    }

    var body: some View {

        @Bindable var vm = viewModel
        
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                Section {

                    // 🔥 SHOW SHIMMER ROWS ONLY
                    if viewModel.employees.isEmpty && viewModel.isSyncing {

                        ForEach(0..<8, id: \.self) { _ in
                            EmployeeRowSkeleton()
                            Divider()
                        }

                    } else {

                        ForEach(viewModel.employees) { employee in
                            EmployeeRowView(employee: employee)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    coordinator.path.append(AppRoute.employeeDetail(employee))
                                }
                                .onAppear {
                                    viewModel.loadMoreIfNeeded(current: employee)
                                }

                            Divider()
                        }
                    }

                } header: {
                    VStack(spacing: 0) {
                        SearchBar(text: $vm.searchText)
                        
                        StatusHeaderView()
                        
                        EmployeeStatusHeaderView()
                    }
                    .containerRelativeFrame(.horizontal)
                }
                
                if viewModel.isLoading && viewModel.canLoadMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                
                if !viewModel.canLoadMore && !viewModel.employees.isEmpty {
                    EndOfListBanner()
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Employees")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            isRefreshing = true
            await viewModel.refresh()
            isRefreshing = false
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showFilters.toggle()
                } label: {
                    Image(systemName: hasActiveFilters
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
//                    .symbolRenderingMode(.hierarchical)
//                    .foregroundStyle(hasActiveFilters ? .blue : .primary)
                }
                .popover(isPresented: $showFilters, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                    GenericFilterPanel(
                        sections: filterSections,
                        preselected: currentSelections,
                        onApply: applyFilters,
                        onReset: resetFilters
                    )
                    .frame(width: 300)
                    .presentationCompactAdaptation(.popover)
                }
            }
        }
        .toolbarBackground(isRefreshing ? .visible : .automatic, for: .navigationBar)
        .toolbarBackground(Color(.white), for: .navigationBar)
        .task {
            await vm.initialLoad()
        }
    }
}

private extension EmployeeListView {

    var filterSections: [FilterSection] {
        [
            .init(
                key: "Department",
                title: "Department",
                options: viewModel.departments,
                allowsMultiple: true
            ),
            .init(
                key: "Role",
                title: "Role",
                options: viewModel.roles,
                allowsMultiple: true
            ),
            .init(
                key: "Status",
                title: "Status",
                options: ["Active", "Inactive"],
                allowsMultiple: false
            )
        ]
    }

    
    var currentSelections: [String: Set<String>] {
        [
            "Department": viewModel.selectedDepartments,
            "Role": viewModel.selectedRoles,
            "Status": Set(viewModel.selectedStatuses.map {
                $0 == .active ? "Active" : "Inactive"
            })
        ]
    }

    func applyFilters(_ dict: [String: Set<String>]) {

        viewModel.selectedDepartments = dict["Department"] ?? []
        viewModel.selectedRoles = dict["Role"] ?? []

        let statusValues = dict["Status"] ?? []

        viewModel.selectedStatuses =
            Set(statusValues.compactMap {
                $0 == "Active" ? .active :
                $0 == "Inactive" ? .inactive : nil
            })
    }

    func resetFilters() {
        viewModel.selectedDepartments = []
        viewModel.selectedRoles = []
        viewModel.selectedStatuses = []
    }
}
