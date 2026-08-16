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

    func openNewBrowserWindow(urls: [URL]?, openWindow: OpenWindowAction) {
        urlsForNewWindow = urls
        openWindow(id: "browser")
    }

    func openNewBrowserWindow(openWindow: OpenWindowAction) {
        openNewBrowserWindow(urls: nil, openWindow: openWindow)
    }

    func openNewBrowserWindowFromDialog(openWindow: OpenWindowAction) {
        showOpenPanel { urls in
            self.openNewBrowserWindow(urls: urls, openWindow: openWindow)
        }
    }

    func showOpenPanel(for window: NSWindow? = nil, onComplete: @escaping ([URL]) -> Void) {
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

    func importFiles(browser: BrowserState) {
        guard let window = browser.context.window else { return }
        showOpenPanel(for: window) { urls in
            Task {
                await browser.manager.importFiles(from: urls)
            }
        }
    }

    func importRecent(browser: BrowserState) {
        guard let url = recentDocumentURLs.first else { return }
        Task {
            await browser.manager.importFiles(from: [url])
        }
    }

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
