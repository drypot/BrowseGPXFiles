//
//  GPXBrowserCommands.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/7/26.
//

import SwiftUI

struct GPXBrowserCommands: Commands {
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.runCommand) private var runCommand

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Open Directory") {
                openWindow(id: "MainWindow")
            }
            .keyboardShortcut("O", modifiers: [.command])
        }
        CommandGroup(after: .toolbar) {
            Button {
                runCommand?(.zoomIn)
            } label: {
                Label("Zoom In", systemImage: "plus.magnifyingglass")
            }
            .keyboardShortcut("+", modifiers: .command)

            Button {
                runCommand?(.zoomOut)
            } label: {
                Label("Zoom Out", systemImage: "minus.magnifyingglass")
            }
            .keyboardShortcut("-", modifiers: .command)

            Button {
                runCommand?(.zoomToFit)
            } label: {
                Label("Zoom to Fit", systemImage: "viewfinder")
            }
            .keyboardShortcut("0", modifiers: .command)
        }
    }
}
