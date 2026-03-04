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
                Button("Open Directory") {
                    openWindow(id: "MainWindow")
                }
                .keyboardShortcut("O", modifiers: [.command])
            }
        }
        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
