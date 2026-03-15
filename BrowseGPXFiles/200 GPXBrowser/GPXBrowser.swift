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

    var initialAction: Action?

    @State private var bufferManager = GPXBufferManager()
    @State private var showImporter = false
    @State private var isLoading = false

    @FocusState private var isFocused: Bool

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
                            Button("Open...") {
                                showImporter = true
                            }
                        }
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
            if isLoading {
                ProgressOverlay(message: "")
            }
        }
        .onAppear {
            bufferManager.undoManager = undoManager
        }
        .focusedSceneValue(\.performAction, performAction)
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.folder, .gpx], allowsMultipleSelection: true) { result in
            showImporter = false
            if case .success(let urls) = result {
                saveBookmark(urls)
                importFiles(urls)
            }
        }
        .onOpenURL { url in
            saveBookmark([url])
            importFiles([url])
        }
        .dropDestination(for: URL.self) { urls, session in
            importFiles(urls)
        }
        .task {
            if let initialAction {
                performAction(initialAction)
            }
        }
    }

    func performAction(_ action: Action) {
        switch action {
        case .openFiles:
            showImporter = true
        case .openRecent:
            importRecent()
        case .zoomToFit:
            bufferManager.zoomToFitAllBuffers()
        default:
            break
        }
    }

    func saveBookmark(_ urls: [URL]) {
        guard let url = urls.first else { return }
        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }
        BookmarkManager.shared.save(url, forKey: "lastOpenFolder")
    }

    func loadBookmark() -> URL? {
        return BookmarkManager.shared.load(forKey: "lastOpenFolder")
    }

    func importFiles(_ urls: [URL]) {
        guard isLoading == false else { return }
        isLoading = true

        Task {
            let start = DispatchTime.now()

            do {
                try await bufferManager.importFilesParallel(urls)
            } catch {
                print("failed to import GPX files: \(error.localizedDescription)")
            }

            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000 // 초 단위 변환
            print("import: \(timeInterval) seconds")

            self.isLoading = false
            bufferManager.zoomToFitAllBuffers()
        }
    }

    func importRecent() {
        if let url = loadBookmark() {
            importFiles([url])
        }
    }
}

#Preview {
    let settings = SettingsData()
    GPXBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
