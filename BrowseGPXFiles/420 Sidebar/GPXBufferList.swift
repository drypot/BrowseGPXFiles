//
//  GPXBufferList.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/17/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct GPXBufferList: View {
    @Environment(AppState.self) var app
    @Environment(GPXBufferManager.self) var manager

    var body: some View {
        @Bindable var manager = manager
        List(manager.filteredBuffers, selection: $manager.selectedBufferIDs) { buffer in
            Text(buffer.name)
        }
        .contextMenu(forSelectionType: GPXBuffer.ID.self ) { ids in
            GPXBufferListContextMenu(selection: ids)
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

