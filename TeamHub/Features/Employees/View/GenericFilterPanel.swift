//
//  GenericFilterPanel.swift
//  TeamHub
//
//  Created by Ayush yadav on 16/02/26.
//

import SwiftUI

struct GenericFilterPanel: View {

    let sections: [FilterSection]
    let preselected: [String: Set<String>]
    let onApply: ([String: Set<String>]) -> Void
    let onReset: () -> Void

    @State private var selections: [String: Set<String>]
    @State private var openedSection: FilterSection? = nil

    @Environment(\.dismiss) private var dismiss

    init(
        sections: [FilterSection],
        preselected: [String: Set<String>],
        onApply: @escaping ([String: Set<String>]) -> Void,
        onReset: @escaping () -> Void
    ) {
        self.sections = sections
        self.preselected = preselected
        self.onApply = onApply
        self.onReset = onReset
        _selections = State(initialValue: preselected)
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {

            Text("Filters")
                .font(.headline)

            ForEach(sections, id: \.self) { section in
                FilterFieldRow(
                    title: section.title,
                    value: displayValue(for: section),
                    action: { openedSection = section }
                )
            }

            Divider()

            HStack {
                Button("Reset") {
                    selections.removeAll()
                    onReset()
                }

                Spacer()

                Button("Done") {
                    onApply(selections)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(height: 300)
        .padding(.horizontal)
//        .padding(14)
//        .frame(width: 320)
//        .fixedSize(horizontal: false, vertical: true)
        .popover(isPresented: Binding(
            get: { openedSection != nil },
            set: { if !$0 { openedSection = nil } }
        )) {
            if let section = openedSection {
                FieldOptionsPopover(
                    title: section.title,
                    options: section.options,
                    allowsMultiple: section.allowsMultiple,
                    selections: Binding(
                        get: { selections[section.key] ?? [] },
                        set: { selections[section.key] = $0 }
                    )
                )
                .frame(width: 200)
                .presentationCompactAdaptation(.popover)
            }
        }
    }
    private func displayValue(for section: FilterSection) -> String {

        let selected = selections[section.key] ?? []

        // nothing selected
        if selected.isEmpty {
            return section.allowsMultiple ? "Any" : "All"
        }

        // single selection (status)
        if !section.allowsMultiple {
            return selected.first ?? "All"
        }

        // multi selection
        return selected.sorted().joined(separator: ", ")
    }

}
