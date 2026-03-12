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
    @Environment(SettingsData.self) var settings

    @Observable
    class ViewState {
        var showImporter = false
        var isLoading = false
        var zoomToFit = false
    }

    @State private var bufferManager = GPXBufferManager()
    @State private var viewState = ViewState()

    var body: some View {
        NavigationSplitView {
            if bufferManager.sortedBuffers.isEmpty {
                Button("Import ...") {
                    viewState.showImporter = true
                }
            } else {
                List(bufferManager.sortedBuffers, id: \.self, selection: $bufferManager.selectedBuffers) { buffer in
                    Text(buffer.name)
                        .contextMenu {
                            Button("Show in Finder") {
                                guard let url = buffer.url else { return }
                                openInFinder(url: url)
                            }
                            Button("Import ...") {
                                viewState.showImporter = true
                            }
                        }
                }
                .onDeleteCommand {
                    bufferManager.removeSelectedBuffers()
                }
                .contextMenu {
                    Button("Import ...") {
                        viewState.showImporter = true
                    }
                }
            }
        } detail: {
            GPXMapView(bufferManager: bufferManager, viewState: viewState)
                .ignoresSafeArea()
        }
        .overlay {
            if viewState.isLoading {
                ProgressOverlay(message: "Importing ...")
            }
        }
        .focusedSceneValue(\.performAction, performAction)
        .fileImporter(isPresented: $viewState.showImporter, allowedContentTypes: [.folder, .gpx], allowsMultipleSelection: true) { result in
            viewState.showImporter = false
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
    }

    func performAction(_ action: Action) {
        switch action {
        case .importFolders:
            viewState.showImporter = true
        case .importRecent:
            importRecent()
        case .zoomToFit:
            viewState.zoomToFit = true
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
        guard viewState.isLoading == false else { return }
        viewState.isLoading = true

        Task.detached(priority: .background) {
            let start = DispatchTime.now()

            do {
                for url in urls {
                    let accessing = url.startAccessingSecurityScopedResource()
                    defer {
                        if accessing { url.stopAccessingSecurityScopedResource() }
                    }
                    try await bufferManager.importGPXFiles(from: url)
                }
            } catch {
                print("failed to import GPX files: \(error.localizedDescription)")
            }

            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000 // 초 단위 변환
            print("import: \(timeInterval) seconds")

            await MainActor.run {
                self.viewState.isLoading = false
                self.viewState.zoomToFit = true
                // print(bufferManager.allBuffers.count)
            }
        }
    }

    func importRecent() {
        if let url = loadBookmark() {
            importFiles([url])
        }
    }

    func openInFinder(url: URL) {
        let path = url.path
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        } else {
            let folderURL = url.deletingLastPathComponent()
            NSWorkspace.shared.open(folderURL)
        }
    }
}

#Preview {
    let settings = SettingsData()
    GPXBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
