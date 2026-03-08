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
            Button {
                runCommand?(.importFolders)
            } label: {
                Label("Import ...", systemImage: "square.and.arrow.down")
            }
            .keyboardShortcut("i", modifiers: .command)

            Button {
                runCommand?(.importRecent)
            } label: {
                Label("Import Recent", systemImage: "square.and.arrow.down.badge.clock")
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
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
