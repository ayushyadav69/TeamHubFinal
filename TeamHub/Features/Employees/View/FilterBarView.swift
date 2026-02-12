//
//  FilterBarView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct FilterBarView: View {

    @Bindable var viewModel: EmployeeListViewModel

    var body: some View {

        ScrollView(.horizontal, showsIndicators: false) {

            HStack(spacing: 12) {

                Picker("Department", selection: $viewModel.selectedDepartment) {
                    Text("All Depts").tag(String?.none)
                    ForEach(viewModel.departments, id: \.self) {
                        Text($0).tag(Optional($0))
                    }
                }
                .pickerStyle(.menu)

                Picker("Role", selection: $viewModel.selectedRole) {
                    Text("All Roles").tag(String?.none)
                    ForEach(viewModel.roles, id: \.self) {
                        Text($0).tag(Optional($0))
                    }
                }
                .pickerStyle(.menu)

                Toggle("Active Only", isOn: $viewModel.showActiveOnly)
                    .toggleStyle(.switch)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.secondarySystemBackground))
    }
}
