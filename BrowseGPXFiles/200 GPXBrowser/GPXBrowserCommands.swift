//
//  GPXBrowserCommands.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/7/26.
//

import SwiftUI

struct GPXBrowserCommands: Commands {
    @FocusedValue(\.performAction) private var performAction

    var body: some Commands {
        CommandGroup(replacing: .importExport) {
            Button("Import ...", systemImage: "square.and.arrow.down") {
                performAction?(.importFolders)
            }
            .keyboardShortcut("i", modifiers: .command)

            Button("Import Recent", systemImage: "square.and.arrow.down.badge.clock") {
                performAction?(.importRecent)
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
        }
        CommandGroup(after: .toolbar) {
            Button("Zoom In", systemImage: "plus.magnifyingglass") {
                performAction?(.zoomIn)
            }
            .keyboardShortcut("+", modifiers: .command)

            Button("Zoom Out", systemImage: "minus.magnifyingglass") {
                performAction?(.zoomOut)
            }
            .keyboardShortcut("-", modifiers: .command)

            Button("Zoom to Fit", systemImage: "viewfinder") {
                performAction?(.zoomToFit)
            }
            .keyboardShortcut("0", modifiers: .command)
        }
    }
}
