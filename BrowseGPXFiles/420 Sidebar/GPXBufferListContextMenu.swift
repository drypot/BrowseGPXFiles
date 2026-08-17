//
//  GPXBufferListContextMenu.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/17/26.
//

import SwiftUI

struct GPXBufferListContextMenu: View {
    @Environment(AppState.self) var app
    @Environment(GPXManager.self) var manager

    var selection: Set<GPXBuffer.ID>

    var body: some View {
        Button("Delete") {
            manager.removeSelectedBuffers()
        }

        if selection.count == 1 {
            Button("Show in Finder") {
                let url = selection.first
                app.openFinder(with: url)
            }
        }
    }
}
