//
//  EmptyStateView.swift
//  TeamHub
//
//  Created by Ayush yadav on 12/02/26.
//

import SwiftUI

struct EmptyStateView: View {

    let message: String
    var retryAction: (() -> Void)? = nil

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 16) {

                Image(systemName: "person.3")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)

                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let retryAction {
                    Button(action: retryAction) {
                        Text("Retry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
