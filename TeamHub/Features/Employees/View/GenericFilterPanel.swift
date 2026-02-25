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
        
        ZStack {
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Filters")
                .font(.headline)
            
            ForEach(sections, id: \.self) { section in
                FilterFieldRow(
                    title: section.title,
                    value: displayValue(for: section),
                    isActive: !(selections[section.key] ?? []).isEmpty,
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
        
        .frame(height: 250)
        .padding(.horizontal)
            if openedSection != nil {
                Color(.label).opacity(0.08)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
    }
        .background(.regularMaterial)
        
//        .opacity(openedSection != nil ? 0.9 : 1)
//        .animation(.easeInOut(duration: 0.15), value: openedSection)
//        .padding(14)
//        .frame(width: 320)
//        .fixedSize(horizontal: false, vertical: true)
        .popover(isPresented: Binding(
            get: { openedSection != nil },
            set: { if !$0 { openedSection = nil } }
        ), attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
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
                .frame(width: 250)
                .presentationCompactAdaptation(.popover)
                .interactiveDismissDisabled()
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
        return String(selected.sorted().count)
    }

}
