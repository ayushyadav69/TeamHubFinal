//
//  DetailView.swift
//  TeamHub
//
//  Created by Ayush yadav on 13/02/26.
//

import SwiftUI

struct DetailView: View {

    let employee: Employee
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ScrollView {
            Rectangle()
                .foregroundStyle(
                    employee.isActive
                    ? Color.green.opacity(scheme == .dark ? 0.25 : 0.4)
                    : Color.red.opacity(scheme == .dark ? 0.35 : 0.8)
                )
                .frame(height: 250)

            Spacer()

            CachedAsyncImage(url: employee.imageURL) { image in
                image.resizable()
            } placeholder: {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(30)
                    .background(Color(.secondarySystemBackground))
            }
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(
                        scheme == .dark
                        ? Color.white.opacity(0.15)
                        : Color.white,
                        lineWidth: scheme == .dark ? 1.5 : 3
                    )
            }
            .shadow(
                color: scheme == .dark ? .black.opacity(0.6) : .black.opacity(0.2),
                radius: 12,
                y: 6
            )
            .offset(y: -130)
            .padding(.bottom, -130)

            VStack {
                VStack {
                    Text(employee.name)
                        .font(.title)
                        .foregroundStyle(.primary)

                    Text(employee.role)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 15) {
                    row("EmployeeId", maskedId(employee.id))
                    row("Department", employee.department)
                    row("Gmail", employee.email)
                    row("City", employee.city)
                    row("Country", employee.country)
                    row("Joining Date", employee.joiningDate.formatted(date: .numeric, time: .omitted))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("Employee Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func maskedId(_ id: String) -> String {
        guard id.count > 8 else { return id }
        let prefix = id.prefix(4)
        let suffix = id.suffix(4)
        return "\(prefix)••••\(suffix)"
    }

    func row(_ title: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
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

    DetailView(
        employee: Employee(
            id: "DL807-zsbwhwhzb-sjhqhh-abb09",
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

