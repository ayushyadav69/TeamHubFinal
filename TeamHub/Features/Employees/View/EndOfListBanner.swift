//
//  EndOfListBanner.swift
//  TeamHub
//
//  Created by Ayush yadav on 20/02/26.
//

import SwiftUI

struct EndOfListBanner: View {

var body: some View {

    VStack(alignment: .leading, spacing: 10) {

        // Headline
        HStack {
            Text("You’ve reached")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("the end. 👋")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.75, blue: 0.45),
                            Color(red: 0.25, green: 0.90, blue: 0.65)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        // colorful playful accent
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [.pink, .orange, .yellow],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 120, height: 4)

        // supporting text
        Text("Try another filter to discover more people")
            .font(.subheadline)
            .foregroundStyle(.secondary)

    }
//    .padding(.top, 44)
//    .padding(.bottom, 70)
    .frame(maxWidth: .infinity, alignment: .leading)
}

}
