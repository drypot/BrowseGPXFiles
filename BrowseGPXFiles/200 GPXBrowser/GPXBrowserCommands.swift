//
//  GPXBrowserCommands.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/7/26.
//

import SwiftUI

struct GPXBrowserCommands: Commands {
    @FocusedValue(\.runCommand) private var runCommand

    var body: some Commands {
        CommandGroup(replacing: .importExport) {
            Button("Import ...", systemImage: "square.and.arrow.down") {
                runCommand?(.importFolders)
            }
            .keyboardShortcut("i", modifiers: .command)

            Button("Import Recent", systemImage: "square.and.arrow.down.badge.clock") {
                runCommand?(.importRecent)
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
        }
        CommandGroup(after: .toolbar) {
            Button("Zoom In", systemImage: "plus.magnifyingglass") {
                runCommand?(.zoomIn)
            }
            .keyboardShortcut("+", modifiers: .command)

            Button("Zoom Out", systemImage: "minus.magnifyingglass") {
                runCommand?(.zoomOut)
            }
            .keyboardShortcut("-", modifiers: .command)

            Button("Zoom to Fit", systemImage: "viewfinder") {
                runCommand?(.zoomToFit)
            }
            .keyboardShortcut("0", modifiers: .command)
        }
    }
}
