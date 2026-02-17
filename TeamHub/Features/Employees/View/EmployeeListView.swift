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

    var body: some View {

        @Bindable var vm = viewModel

        ScrollView {
            StatusHeaderView(isOffline: viewModel.isOffline, isSyncing: viewModel.isLoading)
            LazyVStack {
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
                
                if viewModel.isLoading && viewModel.canLoadMore {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Employees")
        .searchable(text: $vm.searchText, placement: .navigationBarDrawer(displayMode: .always))
        .refreshable {
            isRefreshing = true
            await viewModel.refresh()
            isRefreshing = false
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showFilters.toggle() } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .popover(isPresented: $showFilters,
                         attachmentAnchor: .rect(.bounds),
                         arrowEdge: .top) {
                    GenericFilterPanel(sections: filterSections, preselected: currentSelections, onApply: applyFilters, onReset: resetFilters)
                    .frame(width: 300)
                    .presentationCompactAdaptation(.popover)
                }
            }
            
        }
        
//        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(isRefreshing ? .visible : .automatic, for: .navigationBar)
        .toolbarBackground(Color(.white), for: .navigationBar)
        .task { await vm.initialLoad() }
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
                allowsMultiple: false   // ⭐ tri-state behavior
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
