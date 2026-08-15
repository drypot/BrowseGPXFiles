//
//  BrowseGPXFilesApp.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 2/28/26.
//

import SwiftUI

@main
struct BrowseGPXFilesApp: App {
    @State private var app = AppState()

    var body: some Scene {
        BrowserWindow()
            .environment(app)

        // SettingsWindow()
        //    .environment(app)

        AboutWindow()
    }
}
