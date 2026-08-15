//
//  AppState.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import Foundation

import SwiftUI
import OSLog
import Observation

let logger = Logger()

@Observable
class AppState {

    func openNewBrowserWindow(openWindow: OpenWindowAction) {
        //openNewBrowserWindow(fromFolderURL: nil, fileURL: nil, openWindow: openWindow)
        openWindow(id: "browser")
    }

    func openNewBrowserWindowFromDialog(openWindow: OpenWindowAction) {
        showFolderOpenPanel { url in
            //self.openNewBrowserWindow(fromFolderURL: url, fileURL: nil, openWindow: openWindow)
        }
    }

    func showFolderOpenPanel(onComplete: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                onComplete(url)
            }
        }
    }

    func showFolderOpenPanelFor(_ window: NSWindow, completion: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.canChooseFiles = false
        panel.beginSheetModal(for: window) { response in
            if response == .OK, let url = panel.url {
                completion(url)
            }
        }
    }

}
