//
//  BrowserWindow.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI

struct BrowserWindow: Scene {
    // @Environment(AppState.self) var app

    var body: some Scene {
        WindowGroup("Browser", id: "browser") {
            BrowserContainer()
        }
        .handlesExternalEvents(matching: ["*"])
        .defaultWindowPlacement { proxy, context in
            let displayBounds = context.defaultDisplay.visibleRect
            let size = CGSize(width: displayBounds.width * 2 / 3, height: displayBounds.height * 2 / 3)

            let position = CGPoint(
                x: displayBounds.midX - (size.width / 2),
                y: displayBounds.maxY - size.height - 140)
            return WindowPlacement(position, size: size)
        }
        .commands {
            BrowserCommands()
        }
    }
}

#Preview {
    // BrowserWindow()
}
