//
//  SearchBar.swift
//  TeamHub
//
//  Created by Ayush yadav on 17/02/26.
//

import SwiftUI
import Combine

struct SearchBar: View {
    @Environment(EmployeeListViewModel.self) private var viewModel
    @FocusState var focused: Bool
    
    var body: some View {
        @Bindable var vm = viewModel
        HStack {
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search employees", text: $vm.searchText)
                .textFieldStyle(.plain)
                .focused($focused)
                .onReceive(GlobalKeyboardDismiss.shared) { _ in
                        focused = false
                    }
            
            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.leading)
        .background(Color(.systemBackground)) // blends with navbar like native search
    }
}
