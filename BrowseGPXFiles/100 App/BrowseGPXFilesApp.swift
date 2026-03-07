//
//  BrowseGPXFilesApp.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 2/28/26.
//

import SwiftUI

@main
struct BrowseGPXFilesApp: App {
    @State private var settings = SettingsData()

    var body: some Scene {
        WindowGroup("Browse GPX Files", id: "MainWindow") {
            GPXBrowser()
                .environment(settings)
        }
        .commands {
            GPXBrowserCommands()
        }
        Settings {
            SettingsView()
                .environment(settings)
        }
    }
}
