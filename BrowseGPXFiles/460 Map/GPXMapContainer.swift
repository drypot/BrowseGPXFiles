//
//  GPXMapContainer.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/15/26.
//

import SwiftUI

struct GPXMapContainer: View {
    @Environment(GPXManager.self) var manager

    var body: some View {
        GPXMapRepresentable(bufferManager: manager)
            .ignoresSafeArea()
        // 이 것을 NavigationSplitView 에 붙여 놓으면 Sidebar 가 사라질 때 느려지거나 크래쉬가 난다.
        // .focusedSceneValue(\.performAction, performAction)
    }
}

#Preview {
    // GPXMapContainer()
}
