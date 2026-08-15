//
//  BrowserContext.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI

@Observable
final class BrowserContext {

    // MARK: - ID

    let id = UUID()
    weak var window: NSWindow?

    // MARK: - Status

    var loading = 0

    // MARK: - Alert

    var alertMessage: String = ""
    var hasAlertMessage = false

    // MARK: - Configure

    func configure() {
    }

    func releaseResource() {
    }

    // MARK: - Alert

    func leaveAlert(_ message: String) {
        self.alertMessage = message
        self.hasAlertMessage = true
    }
}
