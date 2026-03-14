//
//  BrowseGPXFilesApp.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 2/28/26.
//

import SwiftUI

// Tailor macOS windows with SwiftUI
// https://developer.apple.com/videos/play/wwdc2024/10148/

@main
struct BrowseGPXFilesApp: App {
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.performAction) private var performAction
    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("Browse GPX Files", id: "browser") {
            GPXBrowser()
                .toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .environment(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Window", systemImage: "macwindow") {
                    openWindow(id: "browser")
                }
                .keyboardShortcut("N", modifiers: [.command, .shift])

                Button("Open...", systemImage: "arrow.up.right") {
                    performAction?(.importFolders)
                }
                .keyboardShortcut("o", modifiers: .command)

                Button("Open Recent", systemImage: "clock") {
                    performAction?(.importRecent)
                }
                .keyboardShortcut("o", modifiers: [.command, .shift])
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
        
        Window("About", id: "about") {
            VStack(spacing: 20) {
                // Image(nsImage: NSApp.applicationIconImage)
                //    .resizable()
                //    .frame(width: 64, height: 64)
                VStack(spacing: 8) {
                    Text("Browse GPX Files")
                        .font(.headline)
                    Text("Version 0.0.1")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Divider()
                Text("© 2026 Kyuhyun Park")
                    .font(.caption)
            }
            .padding(30)
            .frame(width: 300, height: 250)
            .containerBackground(.thickMaterial, for: .window)
            .windowMinimizeBehavior(.disabled)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .restorationBehavior(.disabled)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About BrowseGPXFiles", systemImage: "info.circle") {
                    openWindow(id: "about")
                }
            }
        }

        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
