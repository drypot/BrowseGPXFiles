//
//  GPXBufferBrowser.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import UniformTypeIdentifiers
import MyLibrary

struct GPXBufferBrowser: View {
    @Environment(SettingsData.self) var settings

    @State private var bufferManager = GPXBufferManager()
    @State private var selectedBuffer: GPXBuffer?

    @State private var openFolderIsPresented = false
    @State private var isLoading = false

    var body: some View {
        if bufferManager.buffers.isEmpty {
            Button("Open Folder") {
                openFolderIsPresented = true
            }
            .fileImporter(isPresented: $openFolderIsPresented,
                          allowedContentTypes: [.folder, .gpx],
                          allowsMultipleSelection: true) { result in
                openFolderIsPresented = false
                switch result {
                case .success(let urls):
                    openFiles(from: urls)
                case .failure:
                    break
                }
            }
            Button("Open Last Folder") {
                openLastFolder()
            }
        } else if isLoading {
            Text("loading files...")
        } else {
            NavigationSplitView {
                List(bufferManager.buffers, id: \.self, selection: $selectedBuffer) { buffer in
                    NavigationLink(buffer.name, value: buffer)
                }
            } detail: {
                Text("GPXFiles: \(bufferManager.buffers.count)")
                .padding()
            }
            // .toolbarBackground(.hidden) // macOS 26, 툴바 구분선이 나왔다 사라졌다 한다, 강제로 감추는 옵션.
        }
    }

    func openFiles(from urls: [URL]) {
        guard isLoading == false else { return }
        isLoading = true

//        if !urls.isEmpty {
//            BookmarkManager.shared.save(urls[0], forKey: "lastOpenFolder")
//        }
        Task.detached(priority: .background) {
            do {
                for url in urls {
                    guard url.startAccessingSecurityScopedResource() else {
                        print("startAccessingSecurityScopedResource failed: \(url.absoluteString)")
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

    func openLastFolder() {
        if let url = BookmarkManager.shared.load(forKey: "lastOpenFolder") {
            openFiles(from: [url])
        }
    }
}

#Preview {
    let settings = SettingsData()
    GPXBufferBrowser()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(settings)
}
