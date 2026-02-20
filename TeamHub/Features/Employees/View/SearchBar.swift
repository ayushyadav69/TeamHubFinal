//
//  SearchBar.swift
//  TeamHub
//
//  Created by Ayush yadav on 17/02/26.
//

import SwiftUI
import Combine

struct SearchBar: View {
    @Binding var text: String
    @FocusState var focused: Bool
    
    var body: some View {
        
        HStack(spacing: 8) {
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search employees", text: $text)
                .textFieldStyle(.plain)
                .focused($focused)
                .onReceive(GlobalKeyboardDismiss.shared) { _ in
                        focused = false
                    }
            
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground)) // blends with navbar like native search
    }
}
