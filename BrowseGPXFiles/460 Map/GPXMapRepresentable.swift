//
//  GPXMapRepresentable.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/3/26.
//

import SwiftUI
import MapKit

struct GPXMapRepresentable: NSViewControllerRepresentable {
    @Environment(AppState.self) var app
    @Environment(GPXManager.self) var manager

    func makeNSViewController(context: Context) -> GPXMapController {
        let controller = GPXMapController(app: app, manager: manager)
        manager.mapView = controller.mapView
        return controller
    }

    func updateNSViewController(_ controller: GPXMapController, context: Context) {
    }
}
