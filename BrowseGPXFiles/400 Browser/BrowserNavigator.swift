//
//  BrowserNavigator.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct BrowserNavigator: View {
    // @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser

    var body: some View {
        NavigationSplitView {
            SidebarContainer()
                .frame(minWidth: 200, maxHeight: .infinity)
                //.navigationSplitViewColumnWidth(min: 180, ideal: 260, max: 520)
        } detail: {
            GPXMapContainer()
        }
        .overlay {
            if browser.context.loading > 0 {
                ProgressOverlay(message: "")
            }
        }
    }
    
}
