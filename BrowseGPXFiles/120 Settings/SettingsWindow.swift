//
//  SettingsWindow.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI

struct SettingsWindow: Scene {
    @Environment(AppState.self) var app

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

#Preview {
    // SettingsWindow()
}
