//
//  SidebarContainer.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/15/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct SidebarContainer: View {
    @Environment(AppState.self) var app
    //@Environment(BrowserState.self) var browser
    @Environment(GPXManager.self) var manager

    var body: some View {
        @Bindable var manager = manager
        List(manager.sortedBuffers, id: \.self, selection: $manager.selectedBuffers) { buffer in
            Text(buffer.name)
                .contextMenu {
                    Button("Show in Finder") {
                        guard let url = buffer.url else { return }
                        app.openFinder(with: url)
                    }
                }
        }
        .searchable(text: $manager.searchText, placement: .sidebar)
        .onCutCommand {
            let providers = manager.selectedBuffers.map { NSItemProvider(object: $0.name as NSString) }
            manager.cutToClipboard()
            return providers
        }
        .onCopyCommand {
            manager.copyToClipboard()
            return manager.selectedBuffers.map { NSItemProvider(object: $0.name as NSString) }
        }
        .onPasteCommand(of: [.text]) { _ in
            manager.pasteFromClipboard()
        }
        .onDeleteCommand {
            manager.removeSelectedBuffers()
        }
    }
}

#Preview {
    // SidebarContainer()
}
