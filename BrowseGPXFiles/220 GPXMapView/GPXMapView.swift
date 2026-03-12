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
    @Binding var action: Action

    func makeNSViewController(context: Context) -> GPXMapViewController {
        return GPXMapViewController(bufferManager)
    }

    func updateNSViewController(_ controller: GPXMapViewController, context: Context) {
        let _ = bufferManager.selectedBuffers.count
        controller.updateOverlays()
        performAction(controller)
    }

    func performAction(_ controller: GPXMapViewController) {
        if action != .none {
            Task {
                action = .none
            }
            switch action {
            case .zoomToFit:
                controller.zoomToFitAllOverlays()
            default:
                break
            }
        }
    }
}

#Preview {
    let bufferManager = GPXBufferManager()
    GPXMapView(bufferManager: bufferManager, action: .constant(.none))
}
