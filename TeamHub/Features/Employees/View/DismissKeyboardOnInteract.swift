//
//  DismissKeyboardOnInteract.swift
//  TeamHub
//
//  Created by Ayush yadav on 20/02/26.
//

import SwiftUI
import Combine

final class GlobalKeyboardDismiss {
    static let shared = PassthroughSubject<Void, Never>()
}

struct DismissKeyboardOnInteract: ViewModifier {

    func body(content: Content) -> some View {
        content
            .scrollDismissesKeyboard(.immediately)
            .gesture(
                TapGesture().onEnded {
                    GlobalKeyboardDismiss.shared.send()
                }
            )
    }
}

extension View {
    func dismissKeyboardOnInteract() -> some View {
        modifier(DismissKeyboardOnInteract())
    }
}
