//
//  EmployeeDetailView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct EmployeeDetailView: View {

    @State var viewModel: EmployeeDetailViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            }
            else if let employee = viewModel.employee {
                content(employee)
            }
            else if let error = viewModel.error {
                Text(error).foregroundStyle(.secondary)
            }
            else {
                ProgressView()
            }
        }
        .navigationTitle("Employee")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load()
        }
    }
}

private extension EmployeeDetailView {

    func content(_ employee: Employee) -> some View {
        ScrollView {
            VStack(spacing: 24) {

                AsyncImage(url: employee.imageURL) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(.gray.opacity(0.2))
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())

                VStack(spacing: 8) {
                    Text(employee.name).font(.title2.bold())
                    Text(employee.role).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    row("Department", employee.department)
                    row("City", employee.city)
                    row("Country", employee.country)
                    row("Status", employee.isActive ? "Active" : "Inactive")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
    }

    func row(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value).fontWeight(.medium)
        }
    }
}
