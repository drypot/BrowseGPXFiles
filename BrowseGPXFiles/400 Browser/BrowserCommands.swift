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

            Button("Open...", systemImage: "folder") {
                app.openNewBrowserWindowFromDialog(openWindow: openWindow)
            }
            .keyboardShortcut("o")

            Menu("Open Recent", systemImage: "text.below.folder") {
                let urls = app.recentDocumentURLs
                if urls.isEmpty {
                    Text("No Recent Documents")
                } else {
                    ForEach(urls, id: \.self) { url in
                        Button(url.lastPathComponent) {
                            app.openNewBrowserWindow(urls: [url], openWindow: openWindow)
                        }
                    }
                    Divider()
                    Button("Clear Menu") {
                        app.clearRecentDocuments()
                    }
                }
            }
        }
        CommandGroup(replacing: .importExport) {
            Button("Import...", systemImage: "square.and.arrow.down") {
                guard let browser else { return }
                app.importFiles(browser: browser)
            }
            .keyboardShortcut("i")
            Button("Import Recent", systemImage: "square.and.arrow.down.badge.clock") {
                guard let browser else { return }
                app.importRecent(browser: browser)
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
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
