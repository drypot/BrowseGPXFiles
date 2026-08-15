//
//  BrowserNavigator.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 7/6/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct BrowserNavigator: View {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser
    @Environment(GPXManager.self) var manager
    @Environment(\.undoManager) var undoManager

    var body: some View {
        @Bindable var browser = browser
        NavigationSplitView {
            SidebarContainer()
                .frame(minWidth: 200, maxHeight: .infinity)
                //.navigationSplitViewColumnWidth(min: 180, ideal: 260, max: 520)
        } detail: {
            GPXMapView(bufferManager: manager)
                .ignoresSafeArea()
                // 이 것을 NavigationSplitView 에 붙여 놓으면 Sidebar 가 사라질 때 느려지거나 크래쉬가 난다.
                // .focusedSceneValue(\.performAction, performAction)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    browser.showImporter = true
                } label: {
                    Label("Open", systemImage: "plus")
                }
            }
        }
        .overlay {
            if browser.loading > 0 {
                ProgressOverlay(message: "")
            }
        }
        .fileImporter(isPresented: $browser.showImporter, allowedContentTypes: [.folder, .gpx], allowsMultipleSelection: true) { result in
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
        .dropDestination(for: URL.self) { urls, session in
            Task {
                await openFiles(urls)
            }
        }

//        macOS 15 지원하려고 넣었던 코드인데, 그냥 macOS 26 부터하기로 하자.
//        코딩 실험용 프로젝트인데 걍 최신 버전 따라다니는 것으로;
//
//        .onDrop(of: [.fileURL], isTargeted: $isTargeted) { providers in
//            Task {
//                await openFiles(from: providers)
//            }
//            return true
//        }

        .task {
            manager.undoManager = undoManager
//            if let initialAction {
//                performAction(initialAction)
//            }
        }
    }

//    func performAction(_ action: Action) {
//        switch action {
//        case .openFiles:
//            showImporter = true
//        case .openRecent:
//            Task {
//                await openRecent()
//            }
//        case .zoomToFit:
//            bufferManager.zoom()
//        default:
//            break
//        }
//    }

    func saveBookmark(_ urls: [URL]) {
        guard let url = urls.first else { return }
        BookmarkManager.shared.save(url, forKey: "lastOpenFolder")
    }

    func loadBookmark() -> URL? {
        return BookmarkManager.shared.load(forKey: "lastOpenFolder")
    }

    func openFiles(_ urls: [URL]) async {
        browser.loading += 1

        let start = DispatchTime.now()

        do {
            try await manager.openFilesParallel(urls)
        } catch {
            print("failed to import GPX files: \(error.localizedDescription)")
        }

        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000 // 초 단위 변환
        print("import: \(timeInterval) seconds")

        self.browser.loading -= 1
        manager.zoomToAllBuffers()
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
//    BrowserNavigator()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .environment(settings)
}
