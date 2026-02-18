//
//  EmployeeStatusHeaderView.swift
//  TeamHub
//
//  Created by Ayush yadav on 17/02/26.
//

import SwiftUI

struct EmployeeStatusHeaderView: View {

    @Environment(EmployeeListViewModel.self) private var viewModel
    
    var body: some View {
        HStack {

            card(title: "Total", value: viewModel.totalCount)
            Spacer()
            card(title: "Active", value: viewModel.activeCount)
            Spacer()
            card(title: "Inactive", value: viewModel.inactiveCount)

        }
        .padding()
        .background(.ultraThinMaterial)
        
    }

    private func card(title: String, value: Int) -> some View {

        HStack(spacing: 10) {
            
            Text(title)
                .font(.body)
                .fontWeight(.light)
            
            Text("\(value)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(color(for: title))
        }

    }
}

private extension EmployeeStatusHeaderView {

    func color(for title: String) -> Color {
        switch title {
        case "Total": return .primary
        case "Active": return .green
        case "Inactive": return .red
        default: return .secondary
        }
    }
}
