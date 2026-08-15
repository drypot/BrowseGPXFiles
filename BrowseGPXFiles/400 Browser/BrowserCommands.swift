//
//  BrowserCommands.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI

struct BrowserCommands: Commands {
    @Environment(AppState.self) var app

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    @FocusedValue(BrowserState.self) private var browser: BrowserState?

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("New Window", systemImage: "macwindow") {
                app.openNewBrowserWindow(openWindow: openWindow)
            }
            .keyboardShortcut("n", modifiers: [.command, .control])

            Button("Open...", systemImage: "arrow.up.right") {
                app.openNewBrowserWindowFromDialog(openWindow: openWindow)
            }
            .keyboardShortcut("o")

            // Button("Open Recent", systemImage: "clock") {
            //     performAction?(.openRecent)
            // }
            // .keyboardShortcut("o", modifiers: [.command, .shift])
        }
        CommandGroup(after: .toolbar) {
            // Button("Zoom In", systemImage: "plus.magnifyingglass") {
            //     performAction?(.zoomIn)
            // }
            // .keyboardShortcut("+", modifiers: .command)

            // Button("Zoom Out", systemImage: "minus.magnifyingglass") {
            //     performAction?(.zoomOut)
            // }
            // .keyboardShortcut("-", modifiers: .command)

            // Button("Zoom to Fit", systemImage: "viewfinder") {
            //     performAction?(.zoomToFit)
            // }
            // .keyboardShortcut("0", modifiers: .command)
        }
    }
}
