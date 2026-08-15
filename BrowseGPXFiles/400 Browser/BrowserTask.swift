//
//  BrowserTask.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI

struct BrowserTask: ViewModifier {
    @Environment(AppState.self) var app
    @Environment(BrowserState.self) var browser
    @Environment(GPXManager.self) var manager
    @Environment(\.undoManager) var undoManager

    func body(content: Content) -> some View {
        content
            .task {
                // SceneStorage 가 업데이트 될 때까지 한 사이클 쉰다.
                await Task.yield()
                initialize()
            }

        /*
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
        */
    }

    func initialize() {
        manager.undoManager = undoManager
        if let urls = app.urlsForNewWindow {
            app.urlsForNewWindow = nil
            Task {
                await manager.importFiles(from: urls)
            }
            return
        }
    }
}
