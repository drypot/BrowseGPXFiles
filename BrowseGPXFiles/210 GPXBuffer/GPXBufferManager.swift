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
    private var _allBuffers: Set<GPXBuffer> = []
    private var _polylineDic: [MKPolyline: GPXBuffer] = [:]

    private var _sortedBuffers: [GPXBuffer] = []
    private var _sortedBuffersShouldBeUpdated = true

    public weak var undoManager: UndoManager?
    public weak var mapView: MKMapView?

    public var allBuffers: Set<GPXBuffer> {
        return _allBuffers
    }

    public var sortedBuffers: [GPXBuffer] {
        if _sortedBuffersShouldBeUpdated {
            _sortedBuffers = Array(_allBuffers).sorted { $0.name < $1.name }
            _sortedBuffersShouldBeUpdated = false
        }
        return _sortedBuffers
    }

    // SwiftUI List 뷰가 이 값을 직접 조작하는 경우를 고려해야 한다.
    public var selectedBuffers: Set<GPXBuffer> = [] {
        didSet {
            let inserted = selectedBuffers.subtracting(oldValue)
            let removed = oldValue.subtracting(selectedBuffers)

            for buffer in inserted {
                undoManager?.registerUndo(withTarget: self) {
                    $0.selectedBuffers.remove(buffer)
                }
                buffer.isSelected = true
                updateStrokeColor(of: buffer)
            }

            for buffer in removed {
                undoManager?.registerUndo(withTarget: self) {
                    $0.selectedBuffers.insert(buffer)
                }
                buffer.isSelected = false
                updateStrokeColor(of: buffer)
            }
        }
    }

    public init() {}

    // MARK: - Insert / Delete

    private func addBuffers(_ buffers: [GPXBuffer]) {
        undoManager?.registerUndo(withTarget: self) {
            $0.removeBuffers(buffers)
        }
        _allBuffers.formUnion(buffers)
        for buffer in buffers {
            for polyline in buffer.polylines {
                _polylineDic[polyline] = buffer
            }
        }
        if let mapView {
            for buffer in buffers {
                mapView.addOverlays(buffer.polylines)
            }
        }
        _sortedBuffersShouldBeUpdated = true
    }

    private func removeBuffers(_ buffers: [GPXBuffer]) {
        undoManager?.registerUndo(withTarget: self) {
            $0.addBuffers(buffers)
        }
        _allBuffers.subtract(buffers)
        for buffer in buffers {
            for polyline in buffer.polylines {
                _polylineDic.removeValue(forKey: polyline)
            }
        }
        if let mapView {
            for buffer in buffers {
                mapView.removeOverlays(buffer.polylines)
            }
        }
        _sortedBuffersShouldBeUpdated = true
    }

    public func removeSelectedBuffers() {
        if !selectedBuffers.isEmpty {
            let buffers = Array(selectedBuffers)
            selectedBuffers.removeAll()
            removeBuffers(buffers)
        }
    }

    // MARK: - Polyline

    public func buffer(from polyline: MKPolyline) -> GPXBuffer? {
        return _polylineDic[polyline]
    }

    // MARK: - File I/O

    @concurrent
    public func importFiles(_ urls: [URL]) async throws {
        var buffers: [GPXBuffer] = []
        for url in urls {
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            for url in try GPXFileURLCollector().collectRecursively(from: url) {
                let buffer = try GPXBuffer(contentOf: url)
                buffers.append(buffer)
            }
        }
        await self.addBuffers(buffers)
    }

    @concurrent
    public func importFilesParallel(_ urls: [URL]) async throws {
        nonisolated struct Box: @unchecked Sendable {
            let buffer: GPXBuffer
        }
        try await withThrowingTaskGroup(of: Box.self) { group in
            var accessing: [URL] = []
            for url in urls {
                if url.startAccessingSecurityScopedResource() { accessing.append(url) }
                for url in try GPXFileURLCollector().collectRecursively(from: url) {
                    group.addTask(priority: .userInitiated) {
                        let buffer = try GPXBuffer(contentOf: url)
                        return Box(buffer: buffer)
                    }
                }
            }
            var buffers: [GPXBuffer] = []
            for try await box in group {
                buffers.append(box.buffer)
            }
            await self.addBuffers(buffers)
            for url in accessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
    }

    // MARK: - Clipboard

    func copyToClipboard() {
        var gpxCopies: [GPX] = []
        for buffer in selectedBuffers {
            gpxCopies.append(buffer.gpx)
        }
        Clipboard.shared.gpxCopies = gpxCopies
    }

    func pasteFromClipboard() {
        var buffers: [GPXBuffer] = []
        for gpx in Clipboard.shared.gpxCopies {
            let buffer = GPXBuffer(gpx: gpx)
            buffers.append(buffer)
        }
        addBuffers(buffers)
    }

    // MARK: - Select

    func updateStrokeColor(of buffer: GPXBuffer) {
        for polyline in buffer.polylines {
            if let renderer = mapView?.renderer(for: polyline) as? MKPolylineRenderer {
                renderer.strokeColor = buffer.isSelected ? .red : .blue
            }
        }
    }

    public func selectBuffer(_ buffer: GPXBuffer) {
        selectedBuffers.insert(buffer)
    }

    public func deselectBuffer(_ buffer: GPXBuffer) {
        selectedBuffers.remove(buffer)
    }

    public func selectAllBuffers() {
        selectedBuffers = _allBuffers
//        for buffer in _allBuffers {
//            if !buffer.isSelected {
//                selectBuffer(buffer)
//            }
//        }
    }

    public func deselectAllBuffers() {
        selectedBuffers = []
//        for buffer in _allBuffers {
//            if buffer.isSelected {
//                deselectBuffer(buffer)
//            }
//        }
    }

    public func beginSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
        if let buffer = nearestBuffer(at: mapPoint, with: tolerance) {
            if buffer.isSelected {
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
            if buffer.isSelected {
                deselectBuffer(buffer)
            } else {
                selectBuffer(buffer)
            }
        }
    }

    public func nearestBuffer(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> GPXBuffer? {
        let polyline = self.nearestPolyline(at: mapPoint, with: tolerance)
        return polyline.flatMap { _polylineDic[$0] }
    }

    func nearestPolyline(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> MKPolyline? {
        var nearest: MKPolyline?
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude
        for buffer in _allBuffers {
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
        bufferLoop: for buffer in _allBuffers {
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
        for buffer in buffers {
            selectBuffer(buffer)
        }
    }
}

