//
//  GPXMapViewController+Drawing.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 4/26/25.
//

import Cocoa
import MapKit
import MyLibrary

extension GPXMapViewController {
    func updateOverlays() {
        for buffer in bufferManager.removedBuffers {
            mapView.removeOverlays(buffer.polylines)
        }
        for buffer in bufferManager.selectionChangedBuffers {
            mapView.removeOverlays(buffer.polylines)
        }
        for buffer in bufferManager.addedBuffers {
            mapView.addOverlays(buffer.polylines)
        }
        for buffer in bufferManager.selectionChangedBuffers {
            mapView.addOverlays(buffer.polylines)
        }
    }

    func zoomToFitAllOverlays() {
        var zoomRect = MKMapRect.null
        mapView.overlays.forEach { overlay in
            zoomRect = zoomRect.union(overlay.boundingMapRect)
        }
        if !zoomRect.isNull {
            let edgePadding = NSEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
            mapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: false)
        }
    }
}

