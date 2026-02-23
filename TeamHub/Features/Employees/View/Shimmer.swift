//
//  Shimmer.swift
//  TeamHub
//
//  Created by Ayush yadav on 20/02/26.
//

import SwiftUI

struct Shimmer: ViewModifier {

    @State private var phase: CGFloat = -0.7

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            Color.primary.opacity(0.12),
                            .clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .rotationEffect(.degrees(20))
                    .offset(x: geo.size.width * phase)
                }
                .blendMode(.plusLighter)
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.2)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 0.7
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}
