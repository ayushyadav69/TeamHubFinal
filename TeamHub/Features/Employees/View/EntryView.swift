//
//  EntryView.swift
//  TeamHub
//
//  Created by Ayush yadav on 23/02/26.
//

import SwiftUI

struct EntryView: View {

    @State private var animate = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(animate ? 1 : 0.7)
                    .opacity(animate ? 1 : 0)

                Text("Team Hub")
                    .font(.system(size: 34, weight: .bold))
                    .opacity(animate ? 1 : 0)
            }
        }
        .onAppear {
            startLifecycle()
        }
    }

    private func startLifecycle() {

        // Animate IN
        withAnimation(.easeOut(duration: 0.8)) {
            animate = true
        }

        // Animate OUT before parent removes it
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeIn(duration: 0.4)) {
                animate = false
            }
        }
    }
}
