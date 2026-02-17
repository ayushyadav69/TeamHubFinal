//
//  FilterFieldRow.swift
//  TeamHub
//
//  Created by Ayush yadav on 16/02/26.
//

import SwiftUI

struct FilterFieldRow: View {


    let title: String
    let value: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}
