//
//  BrowserState.swift
//  Browse GPX Files
//
//  Created by Kyuhyun Park on 8/14/26.
//

import SwiftUI
import OSLog

@Observable
final class BrowserState {
    @ObservationIgnored var app: AppState?
    @ObservationIgnored var context: BrowserContext
    @ObservationIgnored var manager: GPXManager

    init() {
        context = BrowserContext()
        manager = GPXManager(context: context)
        logger.debug("init browser state:")
    }

    // MARK: - Configure

    func configure(with rootURL: URL, app: AppState) {
        logger.debug("configure browser state:")
        self.app = app
        context.configure()
    }

    func releaseResource() {
        logger.debug("release browser resource:")
        context.releaseResource()
    }
}

