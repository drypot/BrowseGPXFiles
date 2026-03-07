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

    @State private var openFolderIsPresented = false
    @State private var isLoading = false

    var body: some View {
        if isLoading {
            Text("loading files...")
        } else if bufferManager.sortedBuffers.isEmpty {
            Button("Open Folder") {
                openFolderIsPresented = true
            }
            .fileImporter(isPresented: $openFolderIsPresented,
                          allowedContentTypes: [.folder, .gpx],
                          allowsMultipleSelection: true) { result in
                openFolderIsPresented = false
                switch result {
                case .success(let urls):
                    saveBookmark(urls)
                    openFiles(from: urls)
                case .failure:
                    break
                }
            }
            Button("Open Last Folder") {
                loadBookmarked()
            }
        } else {
            NavigationSplitView {
                List(bufferManager.sortedBuffers, id: \.self, selection: $bufferManager.selectedBuffers) { buffer in
                    NavigationLink(buffer.name, value: buffer)
                }
            } detail: {
                GPXMapView(bufferManager: bufferManager)
                    .navigationTitle("")
                    .ignoresSafeArea(edges: .top)
                    .toolbarBackground(.hidden, for: .windowToolbar)
            }
        }
    }

    func openFiles(from urls: [URL]) {
        guard isLoading == false else { return }
        isLoading = true

        Task.detached(priority: .background) {
            do {
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else {
                        print("failed AccessingSecurityScope: \(url.absoluteString)")
                        break
                    }
                    defer { url.stopAccessingSecurityScopedResource() }
                    try await bufferManager.loadGPXFiles(from: url)
                }
            } catch {
                print("failed to load GPX files: \(error.localizedDescription)")
            }
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    func saveBookmark(_ urls: [URL]) {
        guard let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else {
            print("failed AccessingSecurityScope: \(url.absoluteString)")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        BookmarkManager.shared.save(url, forKey: "lastOpenFolder")
    }

    func loadBookmarked() {
        if let url = BookmarkManager.shared.load(forKey: "lastOpenFolder") {
            openFiles(from: [url])
        }
    }
}

#Preview {
    let settings = SettingsData()
    GPXBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
