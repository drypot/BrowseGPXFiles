//
//  GPXMapViewController+Mouse.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 4/26/25.
//

import Cocoa
import MapKit
import MyLibrary

extension GPXMapViewController {

    override func flagsChanged(with event: NSEvent) {
        isSelectionMode = event.modifierFlags.contains(.command)
        mapView.isScrollEnabled = !isSelectionMode
    }

    override func mouseDown(with event: NSEvent) {
        self.view.window?.makeFirstResponder(self)

        startPoint = view.convert(event.locationInWindow, from: nil)
        isDragging = false
    }

    override func mouseDragged(with event: NSEvent) {
        guard let startPoint else { return }

        let current = view.convert(event.locationInWindow, from: nil)

        let dx = current.x - startPoint.x
        let dy = current.y - startPoint.y
        let distance = sqrt(dx * dx + dy * dy)

        if distance > tolerance {
            isDragging = true

            if isSelectionMode {
                let rect = CGRect(
                    x: min(startPoint.x, current.x),
                    y: min(startPoint.y, current.y),
                    width: abs(dx),
                    height: abs(dy)
                )
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                selectionLayer.frame = view.bounds
                selectionLayer.path = CGPath(rect: rect, transform: nil)
                selectionLayer.isHidden = false
                CATransaction.commit()
            }
        }
    }

    override func mouseUp(with event: NSEvent) {
        if isDragging {
            guard let path = selectionLayer.path else { return }
            let rect = path.boundingBox
            let region = mapView.convert(rect, toRegionFrom: view)
            let mapRect = mapRect(from: region)
            bufferManager.selectBuffers(in: mapRect)
        } else {
            guard let startPoint else { return }
            let p = mapView.convert(startPoint, from: view)
            if event.modifierFlags.contains(.shift) {
                handleShiftClick(at: p)
            } else if event.modifierFlags.contains(.command) {
                handleShiftClick(at: p)
            } else {
                handleClick(at: p)
            }
        }
        startPoint = nil
        isDragging = false
        selectionLayer.isHidden = true
        selectionLayer.path = nil
    }

    func handleClick(at point: NSPoint) {
        let (mapPoint, tolerance) = mapPoint(at: point)
        beginSelection(at: mapPoint, with: tolerance)
    }

    func handleShiftClick(at point: NSPoint) {
        let (mapPoint, tolerance) = mapPoint(at: point)
        toggleSelection(at: mapPoint, with: tolerance)
    }

    func handleCmdClick(at point: NSPoint) {
        let (mapPoint, tolerance) = mapPoint(at: point)
        toggleSelection(at: mapPoint, with: tolerance)
    }

    func beginSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
        bufferManager.beginSelection(at: mapPoint, with: tolerance)
    }

    func toggleSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
        bufferManager.toggleSelection(at: mapPoint, with: tolerance)
    }

    func mapPoint(at point: NSPoint) -> (MKMapPoint, CLLocationDistance) {
        let limit = 10.0
        let p1 = MKMapPoint(mapView.convert(point, toCoordinateFrom: mapView))
        let p2 = MKMapPoint(mapView.convert(CGPoint(x: point.x + limit, y: point.y), toCoordinateFrom: mapView))
        let tolerance = p1.distance(to: p2)
        return (p1, tolerance)
    }

    func mapRect(from region:MKCoordinateRegion) -> MKMapRect {
        let topLeft = CLLocationCoordinate2D(
            latitude: region.center.latitude + region.span.latitudeDelta / 2,
            longitude: region.center.longitude - region.span.longitudeDelta / 2
        )

        let bottomRight = CLLocationCoordinate2D(
            latitude: region.center.latitude - region.span.latitudeDelta / 2,
            longitude: region.center.longitude + region.span.longitudeDelta / 2
        )

        let a = MKMapPoint(topLeft)
        let b = MKMapPoint(bottomRight)

        return MKMapRect(
            x: min(a.x, b.x),
            y: min(a.y, b.y),
            width: abs(a.x - b.x),
            height: abs(a.y - b.y)
        )
    }
}
