//
//  BrowserWindowEvent.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/16/26.
//

import SwiftUI
import OSLog

struct BrowserWindowEvent: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    //@Environment(\.openWindow) private var openWindow
    //@Environment(\.dismissWindow) private var dismissWindow

    //@State private var cancellables = Set<AnyCancellable>()

    func body(content: Content) -> some View {
        content
            .background(WindowAccessor(onResolve: setupWindow))
    }

    func setupWindow(_ window: NSWindow?) {
        logger.debug("setup browser window:")
        guard let window else { return }
        self.browser.context.window = window
    }
}
