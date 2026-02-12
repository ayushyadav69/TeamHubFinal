//
//  EmployeeRowView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct EmployeeRowView: View {

    let employee: Employee

    var body: some View {

        HStack(spacing: 16) {

            AsyncImage(url: employee.imageURL) { image in
                image.resizable()
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
            }
            .frame(width: 48, height: 48)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {

                Text(employee.name)
                    .font(.headline)

                Text(employee.role)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                statusPill
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}
private extension EmployeeRowView {

    var statusPill: some View {
        Text(employee.isActive ? "Active" : "Inactive")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(employee.isActive
                          ? Color.green.opacity(0.15)
                          : Color.red.opacity(0.15))
            )
            .foregroundStyle(employee.isActive ? .green : .red)
    }
}
