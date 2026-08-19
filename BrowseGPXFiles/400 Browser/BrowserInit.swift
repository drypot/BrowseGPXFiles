//
//  BrowserInit.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI

struct BrowserInit: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser
    @Environment(GPXBufferManager.self) var manager
    @Environment(\.undoManager) var undoManager

    func body(content: Content) -> some View {
        content
            .task {
                // SceneStorage를 쓸 경우, SceneStorage 업데이트 될 때까지 한 사이클 쉰다.
                await Task.yield()
                initialize()
            }
            .onOpenURL { url in
                app.importDrop(from: [url], to: browser)
            }
            // macOS 26 부터
            .dropDestination(for: URL.self) { urls, session in
                app.importDrop(from: urls, to: browser)
            }
    }

    func initialize() {
        manager.undoManager = undoManager
        if let urls = app.urlsForNewWindow {
            app.urlsForNewWindow = nil
            Task {
                await manager.importFiles(from: urls)
            }
            return
        }
    }
}
