//
//  EmployeeRowView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct EmployeeRowView: View {

    let employee: Employee
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        HStack {
            CachedAsyncImage(url: employee.imageURL) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
            }
            .frame(width: 60, height: 60)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(
                        scheme == .dark
                        ? Color.white.opacity(0.15)
                        : Color.white,
                        lineWidth: 2
                    )
            }
            .shadow(
                color: scheme == .dark ? .black.opacity(0.6) : .black.opacity(0.15),
                radius: 8,
                y: 4
            )

            VStack(alignment: .leading) {
                HStack {
                    Text(employee.name.capitalized)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer()

                    Text(employee.isActive ? "Active" : "Inactive")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    employee.isActive
                                    ? Color.green.opacity(scheme == .dark ? 0.25 : 0.15)
                                    : Color.red.opacity(scheme == .dark ? 0.25 : 0.15)
                                )
                        )
                        .foregroundStyle(employee.isActive ? .green : .red)
                }

                Text("\(employee.role), \(employee.department)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.leading, 10)
        }
//        .padding(.vertical)
    }
}

#Preview {

    let date: Date = {
        var components = DateComponents()
        components.day = 17
        components.month = 12
        components.year = 2025
        return Calendar.current.date(from: components)!
    }()

    EmployeeRowView(
        employee: Employee(
            id: "DL807",
            name: "Ayush Yadav",
            role: "Intern",
            department: "iOS Development",
            isActive: true,
            imageURL: URL(string: "https://i.pravatar.cc/150?img=2"),
            email: "ayush@gmail.com",
            city: "Kalpi",
            country: "India",
            joiningDate: date
        )
    )
}

