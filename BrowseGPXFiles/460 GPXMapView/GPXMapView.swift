//
//  GPXMapView.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/3/26.
//

import SwiftUI
import MapKit

struct GPXMapView: NSViewControllerRepresentable {
    var bufferManager: GPXManager

    func makeNSViewController(context: Context) -> GPXMapViewController {
        let controller = GPXMapViewController(bufferManager)
        bufferManager.mapView = controller.mapView
        return controller
    }

    func updateNSViewController(_ controller: GPXMapViewController, context: Context) {
    }
}

#Preview {
    let bufferManager = GPXManager()
    GPXMapView(bufferManager: bufferManager)
}
