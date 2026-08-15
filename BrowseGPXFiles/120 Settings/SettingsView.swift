//
//  SettingsView.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 7/17/25.
//

import SwiftUI
import Observation


struct SettingsView: View {
    @Environment(AppState.self) var app

    var body: some View {
        @Bindable var app = app

        Form {
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .fixedSize()
    }
}

#Preview {
    // SettingsView(app: AppState())
}
