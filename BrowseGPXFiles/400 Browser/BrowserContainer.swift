//
//  BrowserContainer.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI
import OSLog

struct BrowserContainer: View {
    @Environment(AppState.self) var app

    @State private var browser = BrowserState()

    var body: some View {
        BrowserNavigator()
            .background(WindowAccessor(onResolve: setupWindow))
            .toolbar(removing: .title)
            .toolbarBackground(.hidden, for: .windowToolbar)
            .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
            .windowToolbarFullScreenVisibility(.onHover)
            .modifier(BrowserTask())
            .focusedSceneValue(browser)
            .environment(browser)
            .environment(browser.context)
            .environment(browser.manager)
    }

    func setupWindow(_ window: NSWindow?) {
        logger.debug("setup browser window:")
        guard let window else { return }
        self.browser.context.window = window
    }
}

#Preview {
    BrowserContainer()
}
