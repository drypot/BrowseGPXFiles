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

    @State private var bufferManager = GPXBufferManager()

    @State private var showImporter = false
    @State private var isLoading = false
    @State private var mapViewCommand: CommandType = .none

    var body: some View {
        NavigationSplitView {
            if bufferManager.sortedBuffers.isEmpty {
                Button("Import ...") {
                    showImporter = true
                }
            } else {
                List(bufferManager.sortedBuffers, id: \.self, selection: $bufferManager.selectedBuffers) { buffer in
                    Text(buffer.name)
                        .contextMenu {
                            Button("Show in Finder") {
                                openInFinder(url: buffer.url)
                            }
                            Button("Import ...") {
                                showImporter = true
                            }
                        }
                }
                .onDeleteCommand {
                    bufferManager.removeSelectedBuffers()
                }
                .contextMenu {
                    Button("Import ...") {
                        showImporter = true
                    }
                }
            }
        } detail: {
            GPXMapView(bufferManager: bufferManager, command: $mapViewCommand)
                .navigationTitle("")
                .ignoresSafeArea(edges: .top)
                .toolbarBackground(.hidden, for: .windowToolbar)
        }
        .focusedSceneValue(\.runCommand) { type in
            runCommand(type)
        }
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
        .overlay {
            if isLoading {
                ProgressOverlay(message: "Importing ...")
            }
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

        Task.detached(priority: .background) {
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
            await MainActor.run {
                self.isLoading = false
                self.mapViewCommand = .zoomToFit
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

    func runCommand(_ type: CommandType) {
        switch type {
        case .importFolders:
            showImporter = true
        case .importRecent:
            importRecent()
        case .zoomToFit:
            mapViewCommand = type
        default:
            break
        }
    }
}

#Preview {
    let settings = SettingsData()
    GPXBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
