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
    private let updateLog = UpdateLog()

    private var _bufferSetUpdated = true
    private(set) var buffers: Set<GPXBuffer> = [] {
        didSet {
            _bufferSetUpdated = true
        }
    }

    private var _sortedBuffers: [GPXBuffer] = []
    public var sortedBuffers: [GPXBuffer] {
        if _bufferSetUpdated {
            _sortedBuffers = Array(buffers).sorted { $0.name < $1.name }
            _bufferSetUpdated = false
        }
        return _sortedBuffers
    }

    private var polylineToBufferDic: [MKPolyline: GPXBuffer] = [:]
    // private var bufferDic: [URL: GPXBuffer] = [:]

    public var selectedBuffers: Set<GPXBuffer> = [] {
        didSet {
            let inserted = selectedBuffers.subtracting(oldValue)
            let removed = oldValue.subtracting(selectedBuffers)

            if !inserted.isEmpty {
                for buffer in inserted {
                    buffer.isSelected = true
                }
                updateLog.logUpdateBuffers(Array(inserted))
            }

            if !removed.isEmpty {
                for buffer in removed {
                    buffer.isSelected = false
                }
                updateLog.logUpdateBuffers(Array(removed))
            }
        }
    }

    public init() {}

    // MARK: - Insert / Delete

    private func addBuffers(_ buffers: [GPXBuffer]) {
        //        undoManager?.registerUndo(withTarget: self) {
        //            $0.removeGPXCaches(buffers)
        //        }
        updateLog.logAddBuffers(buffers)
        self.buffers.formUnion(buffers)
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
        updateLog.logRemoveBuffers(buffers)
        self.buffers.subtract(buffers)
        for buffer in buffers {
            for polyline in buffer.polylines {
                polylineToBufferDic.removeValue(forKey: polyline)
            }
        }
    }

    // MARK: - Polyline

    public func update(_ mapView: MKMapView) {
        updateLog.update(mapView)
    }

    public func buffer(from polyline: MKPolyline) -> GPXBuffer? {
        return polylineToBufferDic[polyline]
    }

    // MARK: - File I/O

    nonisolated public func loadGPXFiles(from url: URL) async throws {
        var buffers: [GPXBuffer] = []

        // TODO: 중복 파일 임포트 방지. 먼 훗날에.
        for url in try GPXFileURLCollector().collectRecursively(from: url) {
            //print("loading: \(url.absoluteString)")
            let buffer = try GPXBuffer(contentOf: url)
            buffers.append(buffer)
        }
        await self.addBuffers(buffers)

//        await MainActor.run {
//            //        undoManager?.disableUndoRegistration()
////            self.addBuffers(buffers)
//            //        undoManager?.enableUndoRegistration()
//
//            //        buffers.append(buffer)
//            //        bufferDic[url] = buffer
//        }
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
        selectedBuffers = self.buffers
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
        if let buffer = nearestGPX(at: mapPoint, with: tolerance) {
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
        if let buffer = nearestGPX(at: mapPoint, with: tolerance) {
            if selectedBuffers.contains(buffer) {
                deselectBuffer(buffer)
            } else {
                selectBuffer(buffer)
            }
        }
    }

    func nearestGPX(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> GPXBuffer? {
        let polyline = self.nearestPolyline(at: mapPoint, with: tolerance)
        return polyline.flatMap { polylineToBufferDic[$0] }
    }

    func nearestPolyline(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> MKPolyline? {
        var nearest: MKPolyline?
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude
        for buffer in buffers {
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

}

