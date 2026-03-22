//
//  GPXBrowser.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

struct GPXBrowser: View {
    @Environment(\.undoManager) var undoManager
    @Environment(SettingsData.self) var settings

    @State private var bufferManager = GPXBufferManager()

    @State private var showImporter = false
    @State private var loading = 0

    @State private var isTargeted = false

    var initialAction: Action?

    init(action: Action? = nil) {
        self.initialAction = action
    }

    var body: some View {
        NavigationSplitView {
            if bufferManager.sortedBuffers.isEmpty {
                Button("Open...") {
                    showImporter = true
                }
            } else {
                List(bufferManager.sortedBuffers, id: \.self, selection: $bufferManager.selectedBuffers) { buffer in
                    Text(buffer.name)
                        .contextMenu {
                            Button("Show in Finder") {
                                guard let url = buffer.url else { return }
                                Finder.shared.open(url: url)
                            }
                        }
                }
                .onCutCommand {
                    let providers = bufferManager.selectedBuffers.map { NSItemProvider(object: $0.name as NSString) }
                    bufferManager.cutToClipboard()
                    return providers
                }
                .onCopyCommand {
                    bufferManager.copyToClipboard()
                    return bufferManager.selectedBuffers.map { NSItemProvider(object: $0.name as NSString) }
                }
                .onPasteCommand(of: [.text]) { _ in
                    bufferManager.pasteFromClipboard()
                }
                .onDeleteCommand {
                    bufferManager.removeSelectedBuffers()
                }
                .contextMenu {
                    Button("Open...") {
                        showImporter = true
                    }
                }
            }
        } detail: {
            GPXMapView(bufferManager: bufferManager)
                .ignoresSafeArea()
        }
        .overlay {
            if loading > 0 {
                ProgressOverlay(message: "")
            }
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.folder, .gpx], allowsMultipleSelection: true) { result in
            if case .success(let urls) = result {
                saveBookmark(urls)
                Task {
                    await openFiles(urls)
                }
            }
        }
        .onOpenURL { url in
            saveBookmark([url])
            Task {
                await openFiles([url])
            }
        }
//        macOS 26 부터
//        .dropDestination(for: URL.self) { urls, session in
//            openFiles(urls)
//        }
        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
            Task {
                await openFiles(from: providers)
            }
            return true
        }
        .task {
            bufferManager.undoManager = undoManager
            if let initialAction {
                performAction(initialAction)
            }
        }
        .focusedSceneValue(\.performAction, performAction)
    }

    func performAction(_ action: Action) {
        switch action {
        case .openFiles:
            showImporter = true
        case .openRecent:
            Task {
                await openRecent()
            }
        case .zoomToFit:
            bufferManager.zoom()
        default:
            break
        }
    }

    func saveBookmark(_ urls: [URL]) {
        guard let url = urls.first else { return }
        BookmarkManager.shared.save(url, forKey: "lastOpenFolder")
    }

    func loadBookmark() -> URL? {
        return BookmarkManager.shared.load(forKey: "lastOpenFolder")
    }

    func openFiles(_ urls: [URL]) async {
        loading += 1

        let start = DispatchTime.now()

        do {
            try await bufferManager.openFilesParallel(urls)
        } catch {
            print("failed to import GPX files: \(error.localizedDescription)")
        }

        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000 // 초 단위 변환
        print("import: \(timeInterval) seconds")

        self.loading -= 1
        bufferManager.zoomToAllBuffers()
    }

    func openRecent() async {
        if let url = loadBookmark() {
            await openFiles([url])
        }
    }

    func openFiles(from providers: [NSItemProvider]) async {
        var urls: [URL] = []
        for provider in providers {
            let url = await withCheckedContinuation { continuation in
                _ = provider.loadObject(ofClass: URL.self) { (url, _) in
                    continuation.resume(returning: url)
                }
            }
            if let url {
                urls.append(url)
            }
        }
        await openFiles(urls)
    }
}

#Preview {
    let settings = SettingsData()
    GPXBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
