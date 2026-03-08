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
        ZStack {
            NavigationSplitView {
                List(bufferManager.sortedBuffers, id: \.self, selection: $bufferManager.selectedBuffers) { buffer in
                    NavigationLink(buffer.name, value: buffer)
                }
                .onDeleteCommand {
                    bufferManager.removeSelectedBuffers()
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
            .fileImporter(isPresented: $showImporter,
                          allowedContentTypes: [.folder, .gpx],
                          allowsMultipleSelection: true) { result in
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

            if isLoading {
                ZStack {
                    Color.black.opacity(0.4) // 배경을 어둡게 처리 (선택 사항)
                        .ignoresSafeArea()

                    VStack(spacing: 12) {
                        ProgressView() // 기본 로딩 애니메이션
                            .controlSize(.large)
                            .tint(.white)

                        Text("Importing ...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial) // 반투명 유리 효과
                    .cornerRadius(12)
                }
                .transition(.opacity) // 나타나고 사라질 때 부드럽게
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
