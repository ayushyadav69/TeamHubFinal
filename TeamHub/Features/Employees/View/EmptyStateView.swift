//
//  EmptyStateView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct EmptyStateView: View {

    let message: String

    var body: some View {
        VStack(spacing: 12) {

            Image(systemName: "person.3")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)

            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
