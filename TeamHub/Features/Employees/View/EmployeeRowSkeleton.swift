//
//  EmployeeRowSkeleton.swift
//  TeamHub
//
//  Created by Ayush yadav on 20/02/26.
//

import SwiftUI

struct EmployeeRowSkeleton: View {

    var body: some View {
        HStack(spacing: 12) {

            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 8) {

                RoundedRectangle(cornerRadius: 6)
                    .fill(.gray.opacity(0.3))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 6)
                    .fill(.gray.opacity(0.25))
                    .frame(width: 120, height: 12)
            }

            Spacer()

            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.25))
                .frame(width: 60, height: 24)
        }
        .padding(.vertical, 8)
        .shimmer()
    }
}
