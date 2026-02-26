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

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Button("Reset") {
                    selections.removeAll()
                }

                Spacer()

                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
//            .padding(.vertical)
            
            Text(title)
                .font(.headline)
                .padding(.bottom, 6)
            
            Divider()

            ScrollView {

                

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
                        .padding(.bottom, 4)
                    }
                    
                
            }
            
        }
        .padding()
        .background(.regularMaterial)
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
