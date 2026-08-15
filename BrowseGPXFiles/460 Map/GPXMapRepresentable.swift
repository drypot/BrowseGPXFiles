//
//  GPXMapRepresentable.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/3/26.
//

import SwiftUI
import MapKit

struct GPXMapRepresentable: NSViewControllerRepresentable {
    var bufferManager: GPXManager

    func makeNSViewController(context: Context) -> GPXMapController {
        let controller = GPXMapController(bufferManager)
        bufferManager.mapView = controller.mapView
        return controller
    }

    func updateNSViewController(_ controller: GPXMapController, context: Context) {
    }
}
