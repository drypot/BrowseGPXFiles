//
//  BrowseGPXFilesApp.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 2/28/26.
//

import SwiftUI

@main
struct BrowseGPXFilesApp: App {
    @Environment(\.openWindow) private var openWindow
    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("Browse GPX Files", id: "MainWindow") {
            GPXBrowser()
                .environment(settings)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Browser") {
                    openWindow(id: "MainWindow")
                }
                .keyboardShortcut("N", modifiers: [.command])
            }
            GPXBrowserCommands()
        }
        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
