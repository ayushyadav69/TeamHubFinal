//
//  FieldOptionsPopover.swift
//  TeamHub
//
//  Created by Ayush yadav on 16/02/26.
//

import SwiftUI

struct FieldOptionsPopover: View {

    let title: String
    let options: [String]
    let allowsMultiple: Bool

    @Binding var selections: Set<String>

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .font(.headline)
                .padding(.bottom, 6)

            ForEach(options, id: \.self) { option in
                Button {
                    select(option)
                } label: {
                    HStack {
                        Text(option)
                        Spacer()

                        if selections.contains(option) {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                }
                
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
        }
        .padding(14)
//        .fixedSize()
    }

    private func select(_ value: String) {
        if allowsMultiple {
            if selections.contains(value) {
                selections.remove(value)
            } else {
                selections.insert(value)
            }
        } else {
            if selections.contains(value) {
                selections.removeAll() // none = show both
            } else {
                selections = [value]
            }
        }
    }
}
