//
//  ProgressOverlay.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/9/26.
//

import SwiftUI

struct ProgressOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                    .tint(.white)

                if !message.isEmpty {
                    Text(message)
                        .font(.callout)
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .transition(.opacity) // 나타나고 사라질 때 부드럽게
    }
}

#Preview {
    ProgressOverlay(message: "")
}
