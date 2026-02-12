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

    var body: some View {

        @Bindable var vm = viewModel

        NavigationStack {
            VStack(spacing: 0) {

                // Status Header (Online / Offline / Syncing)
                StatusHeaderView(
                    isOffline: vm.isOffline,
                    isSyncing: vm.isLoading
                )

                // Filter Bar
                FilterBarView(viewModel: vm)

                Divider()

                content(vm: vm)
            }
            .navigationTitle("Employees")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $vm.searchText)
            .task {
                await vm.initialLoad()
            }
            .refreshable {
                await vm.refresh()
            }
        }
    }
}
private extension EmployeeListView {

    func content(vm: EmployeeListViewModel) -> some View {

        Group {
            if vm.isLoading && vm.employees.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if vm.employees.isEmpty {
                EmptyStateView(message: "No employees found")
            }
            else {
                list(vm: vm)
            }
        }
    }

    func list(vm: EmployeeListViewModel) -> some View {

        List {
            ForEach(vm.employees) { employee in
                EmployeeRowView(employee: employee)
                    .contentShape(Rectangle()) // full row tappable
                    .onTapGesture {
                        coordinator.goToDetail(employeeID: employee.id)
                    }
                    .onAppear {
                        vm.loadMoreIfNeeded(current: employee)
                    }
            }

            if vm.isLoading && vm.canLoadMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
        }
        .listStyle(.plain)
    }

}
private extension EmployeeListView {

    func statsSection(vm: EmployeeListViewModel) -> some View {

        HStack(spacing: 16) {

            statItem(title: "Total", value: vm.totalCount, color: .primary)

            statItem(title: "Active", value: vm.activeCount, color: .green)

            statItem(title: "Inactive", value: vm.inactiveCount, color: .red)

            Spacer()
        }
        .padding(.vertical, 8)
    }

    func statItem(title: String, value: Int, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(value)")
                .font(.headline)
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
