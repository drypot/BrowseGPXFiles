//
//  BrowserToolbar.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/15/26.
//

import SwiftUI

struct BrowserToolbar: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow

    func body(content: Content) -> some View {
        content
            .windowToolbarFullScreenVisibility(.onHover)
            .toolbarBackground(.hidden, for: .windowToolbar)
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
        //.navigationTitle(browser.context.rootName ?? "Browser")
            .toolbar(removing: .title)
            .toolbar {
                toolbarContent
            }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                app.importFromDialog(to: browser)
            } label: {
                Label("Import", systemImage: "plus")
            }
        }
    }
}

//#Preview {
//    BrowserToolbar()
//}
