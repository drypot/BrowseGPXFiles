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

    func makeNSViewController(context: Context) -> GPXMapViewController {
        return GPXMapViewController(bufferManager)
    }

    func updateNSViewController(_ controller: GPXMapViewController, context: Context) {
        print("update")
        let _ = bufferManager.selectedBuffers.count
        controller.updateOverlays()
    }
}

#Preview {
    let bufferManager = GPXBufferManager()
    GPXMapView(bufferManager: bufferManager)
}
