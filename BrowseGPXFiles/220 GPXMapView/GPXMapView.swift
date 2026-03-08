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
    @Binding var command: CommandType

    func makeNSViewController(context: Context) -> GPXMapViewController {
        return GPXMapViewController(bufferManager)
    }

    func updateNSViewController(_ controller: GPXMapViewController, context: Context) {
        let _ = bufferManager.selectedBuffers.count
        controller.updateOverlays()
        runCommand(controller)
    }

    func runCommand(_ controller: GPXMapViewController) {
        if command != .none {
            switch command {
            case .zoomToFit:
                controller.zoomToFitAllOverlays()
            default:
                break
            }
            Task {
                command = .none
            }
        }
    }
}

#Preview {
    let bufferManager = GPXBufferManager()
    GPXMapView(bufferManager: bufferManager, command: .constant(.none))
}
