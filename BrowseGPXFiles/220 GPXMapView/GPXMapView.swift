//
//  GPXMapView.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/3/26.
//

import SwiftUI
import MapKit
import MyLibrary

struct GPXMapView: NSViewControllerRepresentable {
    var bufferManager: GPXBufferManager
    var viewState: GPXBrowser.ViewState

    func makeNSViewController(context: Context) -> GPXMapViewController {
        let controller = GPXMapViewController(bufferManager, viewState)
        bufferManager.mapView = controller.mapView
        return controller
    }

    func updateNSViewController(_ controller: GPXMapViewController, context: Context) {
//        let _ = bufferManager.allBuffers.count
        let _ = bufferManager.selectedBuffers.count
        controller.updateOverlays()
        if viewState.zoomToFit {
            Task { viewState.zoomToFit = false }
            controller.zoomToFitAllOverlays()
        }
    }
}

#Preview {
    let bufferManager = GPXBufferManager()
    GPXMapView(bufferManager: bufferManager, viewState: .init())
}
