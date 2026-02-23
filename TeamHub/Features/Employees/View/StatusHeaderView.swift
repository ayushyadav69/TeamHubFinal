//
//  StatusHeaderView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct StatusHeaderView: View {
    
    @Environment(EmployeeListViewModel.self) private var viewModel

    var body: some View {

        HStack(spacing: 12) {

            Circle()
                .fill(viewModel.isOffline ? .red : .green)
                .frame(width: 8, height: 8)

            if viewModel.isOffline {
                Text("Offline mode")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            else if viewModel.isSyncing  {
                Text("Syncing...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            else {
                Text("Online")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
        
    }
}
