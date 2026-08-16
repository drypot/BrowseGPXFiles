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
            .modifier(BrowserToolbar())
            //.modifier(BrowserSheet())
            .modifier(BrowserWindowEvent())
            .modifier(BrowserInit())
            .environment(browser)
            .environment(browser.context)
            .environment(browser.manager)
            .focusedSceneValue(browser)
    }
}
