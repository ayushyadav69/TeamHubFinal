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
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        
            HStack {
                Text(title)

                if isActive {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 7, height: 7)
                }

                Spacer()

                Text(value)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }
}
