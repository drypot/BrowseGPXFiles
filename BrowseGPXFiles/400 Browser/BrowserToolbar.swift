//
//  BrowserToolbar.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/15/26.
//

import SwiftUI

struct BrowserToolbar: ToolbarContent {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                app.importFiles(browser: browser)
            } label: {
                Label("Import", systemImage: "plus")
            }
        }
    }
}

//#Preview {
//    BrowserToolbar()
//}
