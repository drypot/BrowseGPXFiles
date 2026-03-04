//
//  GPXMapViewController+MapViewDelegate.swift
//  GPXApp
//
//  Created by Kyuhyun Park on 5/16/25.
//

import Cocoa
import MapKit
import MyLibrary

extension GPXMapViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            if let buffer = bufferManager.polylineToGPXCacheMap[polyline] {
                let renderer = MKPolylineRenderer(polyline: polyline)
                if buffer.isSelected {
                    renderer.strokeColor = .red
                } else {
                    renderer.strokeColor = .blue
                }
                renderer.lineWidth = 3.0
                return renderer
            }
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}
