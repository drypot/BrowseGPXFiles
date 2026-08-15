//
//  BrowserTask.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI

struct BrowserTask: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    func body(content: Content) -> some View {
        content
    }
}
