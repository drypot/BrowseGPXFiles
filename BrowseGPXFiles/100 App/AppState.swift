//
//  AppState.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import Foundation

import SwiftUI
import UniformTypeIdentifiers
import OSLog

let logger = Logger()

@Observable
class AppState {

    @ObservationIgnored var urlsForNewWindow: [URL]?

    var recentDocumentURLs: [URL]

    init() {
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    // MARK: - Browser Window

    func newBrowserWindow(with urls: [URL]? = nil, openWindow: OpenWindowAction) {
        urlsForNewWindow = urls
        openWindow(id: "browser")
    }

    func newBrowserWindowFromDialog(openWindow: OpenWindowAction) {
        showOpenPanel { urls in
            self.newBrowserWindow(with: urls, openWindow: openWindow)
        }
    }

    private func showOpenPanel(for window: NSWindow? = nil, onComplete: @escaping ([URL]) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.folder, .gpx]
        if let window {
            panel.beginSheetModal(for: window) { response in
                if response == .OK {
                    let urls = panel.urls
                    self.addRecentDocumentURLs(urls)
                    onComplete(urls)
                }
            }
        } else {
            panel.begin { response in
                if response == .OK {
                    let urls = panel.urls
                    self.addRecentDocumentURLs(urls)
                    onComplete(urls)
                }
            }
        }
    }

    func importFromDialog(to browser: BrowserState) {
        guard let window = browser.context.window else { return }
        showOpenPanel(for: window) { urls in
            Task {
                await browser.manager.importFiles(from: urls)
            }
        }
    }

    func importRecent(to browser: BrowserState) {
        guard let url = recentDocumentURLs.first else { return }
        Task {
            await browser.manager.importFiles(from: [url])
        }
    }

    func importDrop(from urls: [URL], to browser: BrowserState) {
        self.addRecentDocumentURLs(urls)
        Task {
            await browser.manager.importFiles(from: urls)
        }
    }

    /*
    // macOS 26 이전 지원용 코드
    func importFiles(from providers: [NSItemProvider], to browser: BrowserState) async {
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
        Task {
            await browser.manager.importFiles(from: urls)
        }
    }
    */

    // MARK: - RecentDocuments

    func addRecentDocumentURLs(_ urls: [URL]) {
        urls.forEach(NSDocumentController.shared.noteNewRecentDocumentURL)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func addRecentDocumentURL(_ url: URL) {
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    func clearRecentDocuments() {
        NSDocumentController.shared.clearRecentDocuments(nil)
        recentDocumentURLs = NSDocumentController.shared.recentDocumentURLs
    }

    // MARK: - Finder

    func openFinder(with url: URL?) {
        guard let url else { return }
        let path = url.path(percentEncoded: false)
        if FileManager.default.fileExists(atPath: path) {
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
        } else {
            let folderURL = url.deletingLastPathComponent()
            NSWorkspace.shared.open(folderURL)
        }
    }

}
