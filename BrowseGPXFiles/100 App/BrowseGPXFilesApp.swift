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
    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("Browse GPX Files", id: "main") {
            GPXBrowser()
                .toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
//                .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
                .environment(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Browser") {
                    openWindow(id: "main")
                }
                .keyboardShortcut("N", modifiers: [.command])
            }
            GPXBrowserCommands()
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
                Button {
                    openWindow(id: "about")
                } label: {
                    Label("About BrowseGPXFiles", systemImage: "info.circle")
                }
            }
        }

        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
