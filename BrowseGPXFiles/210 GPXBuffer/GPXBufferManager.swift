//
//  GPXBufferManager.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MapKit
import MyLibrary

@MainActor @Observable
public class GPXBufferManager {
    private let mapViewUpdater = MapViewUpdater()

    private var _buffersUpdated = true
    private(set) var allBuffers: Set<GPXBuffer> = [] {
        didSet {
            _buffersUpdated = true
        }
    }

    private var _sortedBuffers: [GPXBuffer] = []
    public var sortedBuffers: [GPXBuffer] {
        if _buffersUpdated {
            _sortedBuffers = Array(allBuffers).sorted { $0.name < $1.name }
            _buffersUpdated = false
        }
        return _sortedBuffers
    }

    private var polylineToBufferDic: [MKPolyline: GPXBuffer] = [:]

    public var selectedBuffers: Set<GPXBuffer> = [] {
        didSet {
            let inserted = selectedBuffers.subtracting(oldValue)
            let removed = oldValue.subtracting(selectedBuffers)

            if !inserted.isEmpty {
                for buffer in inserted {
                    buffer.isSelected = true
                }
                mapViewUpdater.queueUpdateColor(Array(inserted))
            }

            if !removed.isEmpty {
                for buffer in removed {
                    buffer.isSelected = false
                }
                mapViewUpdater.queueUpdateColor(Array(removed))
            }
        }
    }

    public init() {}

    // MARK: - Insert / Delete

    private func addBuffers(_ buffers: [GPXBuffer]) {
        //        undoManager?.registerUndo(withTarget: self) {
        //            $0.removeGPXCaches(buffers)
        //        }
        mapViewUpdater.queueAddBuffers(buffers)
        self.allBuffers.formUnion(buffers)
        for buffer in buffers {
            for polyline in buffer.polylines {
                polylineToBufferDic[polyline] = buffer
            }
        }
    }

    private func removeBuffers(_ buffers: [GPXBuffer]) {
        //        undoManager?.registerUndo(withTarget: self) {
        //            $0.addGPXCaches(buffers)
        //        }
        mapViewUpdater.queueRemoveBuffers(buffers)
        self.allBuffers.subtract(buffers)
        for buffer in buffers {
            for polyline in buffer.polylines {
                polylineToBufferDic.removeValue(forKey: polyline)
            }
        }
    }

    // MARK: - Polyline

    public func updateMapView(_ mapView: MKMapView) {
        mapViewUpdater.flush(to: mapView)
    }

    public func buffer(from polyline: MKPolyline) -> GPXBuffer? {
        return polylineToBufferDic[polyline]
    }

    // MARK: - File I/O

    nonisolated public func importGPXFiles(from url: URL) async throws {
        var buffers: [GPXBuffer] = []

        for url in try GPXFileURLCollector().collectRecursively(from: url) {
            let exist = await self.allBuffers.contains { $0.gpx.url == url }
            guard !exist else { continue }
            //print("loading: \(url.absoluteString)")
            let buffer = try GPXBuffer(contentOf: url)
            buffers.append(buffer)
        }
        await self.addBuffers(buffers)

//        await MainActor.run {
//            //        undoManager?.disableUndoRegistration()
////            self.addBuffers(buffers)
//            //        undoManager?.enableUndoRegistration()
//            ...
//        }
    }

    // MARK: - Clipboard

//    func gpxCopies() -> [GPX] {
//        return selectedBuffers.map(\.gpx)
//    }

    func copyToClipboard() {
        var gpxCopies: [GPX] = []
        for buffer in selectedBuffers {
            gpxCopies.append(buffer.gpx)
        }
        Clipboard.shared.gpxCopies = gpxCopies
    }

//    func paste(_ gpxCopies: [GPX]) {
//        let buffers = gpxCopies.map { GPXBuffer(gpx: $0) }
//        addBuffers(buffers)
//    }

    func paseteFromClipboard() {
        var buffers: [GPXBuffer] = []
        for gpx in Clipboard.shared.gpxCopies {
            let buffer = GPXBuffer(gpx: gpx)
            buffers.append(buffer)
        }
        addBuffers(buffers)
    }

    // MARK: - Select

    func selectBuffer(_ buffer: GPXBuffer) {
        //        undoManager?.registerUndo(withTarget: self) {
        //            $0.deselectGPXCache(buffer)
        //        }
        selectedBuffers.insert(buffer)
    }

    func deselectBuffer(_ buffer: GPXBuffer) {
        //        undoManager?.registerUndo(withTarget: self) {
        //            $0.selectGPXCache(buffer)
        //        }
        //        buffer.isSelected = false
        selectedBuffers.remove(buffer)
    }

    public func selectAllBuffers() {
        selectedBuffers = self.allBuffers
        //        for buffer in buffers {
        //            if !buffer.isSelected {
        //                selectBuffer(buffer)
        //            }
        //        }
    }

    public func deselectAllBuffers() {
        //        undoManager? ...
        //        for buffer in buffers {
        //            if buffer.isSelected {
        //                deselectBuffer(buffer)
        //            }
        //        }
        selectedBuffers.removeAll()
    }

    public func removeSelectedBuffers() {
        //        let selectedBuffers = buffers.filter { $0.isSelected }
        if !selectedBuffers.isEmpty {
            removeBuffers(Array(selectedBuffers))
            selectedBuffers.removeAll()
        }
    }

    public func beginSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
        if let buffer = nearestBuffer(at: mapPoint, with: tolerance) {
            if selectedBuffers.contains(buffer) {
                deselectAllBuffers()
            } else {
                deselectAllBuffers()
                selectBuffer(buffer)
            }
        } else {
            deselectAllBuffers()
        }
    }

    public func toggleSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
        if let buffer = nearestBuffer(at: mapPoint, with: tolerance) {
            if selectedBuffers.contains(buffer) {
                deselectBuffer(buffer)
            } else {
                selectBuffer(buffer)
            }
        }
    }

    public func nearestBuffer(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> GPXBuffer? {
        let polyline = self.nearestPolyline(at: mapPoint, with: tolerance)
        return polyline.flatMap { polylineToBufferDic[$0] }
    }

    func nearestPolyline(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> MKPolyline? {
        var nearest: MKPolyline?
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude
        for buffer in allBuffers {
            for polyline in buffer.polylines {
                let rect = polyline.boundingMapRect.insetBy(dx: -tolerance, dy: -tolerance)
                if !rect.contains(mapPoint) {
                    continue
                }
                let distance = GPXUtility.calcDistance(from: mapPoint, to: polyline)
                if distance < tolerance, distance < minDistance {
                    minDistance = distance
                    nearest = polyline
                }
            }
        }
        return nearest
    }

    func selectBuffers(in rect: MKMapRect) {
        var buffers: [GPXBuffer] = []
        bufferLoop: for buffer in allBuffers {
            guard !buffer.isSelected else { continue }
            for polyline in buffer.polylines {
                guard polyline.boundingMapRect.intersects(rect) else { continue }
                let points = polyline.points()
                for i in 0..<polyline.pointCount {
                    if rect.contains(points[i]) {
                        buffers.append(buffer)
                        continue bufferLoop
                    }
                }
            }
        }
        selectedBuffers.formUnion(buffers)
    }
}

