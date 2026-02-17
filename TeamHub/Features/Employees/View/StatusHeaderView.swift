//
//  StatusHeaderView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct StatusHeaderView: View {

    let isOffline: Bool
    let isSyncing: Bool

    var body: some View {

        HStack(spacing: 12) {

            Circle()
                .fill(isOffline ? .red : .green)
                .frame(width: 8, height: 8)

            if isOffline {
                Text("Offline mode")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            else if isSyncing {
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
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        
    }
}
