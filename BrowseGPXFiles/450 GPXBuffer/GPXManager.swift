//
//  GPXManager.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MapKit
import OSLog

@Observable
class GPXManager {
    // MARK: - All Buffers

    private(set) var allBuffers: [GPXBuffer.ID: GPXBuffer] = [:] {
        didSet {
            _filteredBuffersShouldBeUpdated = true
        }
    }

    // MARK: - Filtered Buffers

    private var _filteredBuffers: [GPXBuffer] = []
    private var _filteredBuffersShouldBeUpdated = true

    var filteredBuffers: [GPXBuffer] {
        if _filteredBuffersShouldBeUpdated {
            let buffers: [GPXBuffer]
            if searchText.isEmpty {
                buffers = Array(allBuffers.values)
            } else {
                buffers = allBuffers.values.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
            _filteredBuffers = buffers.sorted { $0.name < $1.name }
            _filteredBuffersShouldBeUpdated = false
        }
        return _filteredBuffers
    }

    var searchText = "" {
        didSet {
            _filteredBuffersShouldBeUpdated = true
        }
    }

    // MARK: - Selected Buffers

    // SwiftUI List 뷰가 이 값을 직접 조작하는 경우를 고려해야 한다.
    var selectedBufferIDs: Set<GPXBuffer.ID> = [] {
        didSet {
            let inserted = selectedBufferIDs.subtracting(oldValue)
            let removed = oldValue.subtracting(selectedBufferIDs)

            for id in inserted {
                undoManager?.registerUndo(withTarget: self) {
                    $0.selectedBufferIDs.remove(id)
                }
                if let buffer = allBuffers[id] {
                    buffer.isSelected = true
                    if let mapView {
                        buffer.updatePolylines(on: mapView)
                    }
                }
            }

            for id in removed {
                undoManager?.registerUndo(withTarget: self) {
                    $0.selectedBufferIDs.insert(id)
                }
                if let buffer = allBuffers[id] {
                    buffer.isSelected = false
                    if let mapView {
                        buffer.updatePolylines(on: mapView)
                    }
                }
            }
        }
    }

    var selectedBuffers: [GPXBuffer] {
        allBuffers.values.filter { selectedBufferIDs.contains($0.id) }
    }

    // MARK: - PolylineDic

    private var polylineDic: [MKPolyline: GPXBuffer] = [:]

    // MARK: - Status

    var loading = false

    // MARK: - Init

    @ObservationIgnored private var context: BrowserContext

    @ObservationIgnored weak var mapView: MKMapView?
    @ObservationIgnored weak var undoManager: UndoManager?

    init(context: BrowserContext) {
        self.context = context
    }

    // MARK: - Insert / Delete

    private func addBuffers(_ buffers: [GPXBuffer]) {
        undoManager?.registerUndo(withTarget: self) {
            $0.removeBuffers(buffers)
        }
        for buffer in buffers {
            allBuffers[buffer.id] = buffer
            for polyline in buffer.polylines {
                polylineDic[polyline] = buffer
            }
        }
        if let mapView {
            for buffer in buffers {
                buffer.addOverlays(on: mapView)
            }
        }
    }

    private func removeBuffers(_ buffers: [GPXBuffer]) {
        undoManager?.registerUndo(withTarget: self) {
            $0.addBuffers(buffers)
        }
        for buffer in buffers {
            allBuffers.removeValue(forKey: buffer.id)
            for polyline in buffer.polylines {
                polylineDic.removeValue(forKey: polyline)
            }
        }
        if let mapView {
            for buffer in buffers {
                buffer.removeOverlays(on: mapView)
            }
        }
    }

    func removeSelectedBuffers() {
        guard !selectedBufferIDs.isEmpty else { return }
        let buffers = selectedBuffers
        selectedBufferIDs.removeAll()
        removeBuffers(buffers)
    }

    // MARK: - Polyline

    func findBuffer(with polyline: MKPolyline) -> GPXBuffer? {
        return _polylineDic[polyline]
    }

    // MARK: - File I/O

//    @concurrent
//    private func importFiles(_ urls: [URL]) async throws {
//        var buffers: [GPXState] = []
//        for url in urls {
//            let securityScoped = url.startAccessingSecurityScopedResource()
//            defer { if securityScoped { url.stopAccessingSecurityScopedResource() } }
//            for url in try GPXFileURLCollector().collectRecursively(from: url) {
//                let buffer = try GPXState(contentOf: url)
//                buffers.append(buffer)
//            }
//        }
//        await self.addBuffers(buffers)
//    }

    @concurrent
    private func importFilesParallel(from urls: [URL]) async throws {
        nonisolated struct Box: @unchecked Sendable {
            let buffer: GPXBuffer
        }
        try await withThrowingTaskGroup(of: Box.self) { group in
            var securityScoped: [URL] = []
            defer {
                for url in securityScoped {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            for url in urls {
                if url.startAccessingSecurityScopedResource() {
                    securityScoped.append(url)
                }
                for url in try Self.collectURLRecursively(at: url) {
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
        }
    }

    nonisolated private static func collectURLRecursively(at url: URL) throws -> [URL] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey, .contentTypeKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let values = try url.resourceValues(forKeys: keySet)

        if values.isRegularFile == true {
            if values.contentType?.conforms(to: .gpx) == true {
                return [url]
            }
        }

        if values.isDirectory == true {
            guard let enumerator = fileManager.enumerator(at: url,
                                                          includingPropertiesForKeys: keys,
                                                          options: options) else { return [] }
            var results: [URL] = []
            for case let url as URL in enumerator {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isRegularFile == true {
                        if values.contentType?.conforms(to: .gpx) == true {
                            results.append(url)
                        }
                    }
                }
            }
            return results
        }

        return []
    }

    func importFiles(from urls: [URL]) async {
        loading = true

        let start = DispatchTime.now()
        do {
            try await importFilesParallel(from: urls)
        } catch {
            logger.error("failed to import GPX files: \(error.localizedDescription)")
        }
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000 // 초 단위 변환
        logger.info("import: \(timeInterval) seconds")

        loading = false
        zoomToAllBuffers()
    }

    // MARK: - Clipboard

    func cutToClipboard() {
        copyToClipboard()
        removeSelectedBuffers()
    }

    func copyToClipboard() {
        var gpxCopies: [GPXFile] = []
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

    func selectBuffer(_ buffer: GPXBuffer) {
        selectedBufferIDs.insert(buffer.id)
    }

    func deselectBuffer(_ buffer: GPXBuffer) {
        selectedBufferIDs.remove(buffer.id)
    }

    func selectAllBuffers() {
        selectedBufferIDs = Set(allBuffers.keys)
    }

    func deselectAllBuffers() {
        selectedBufferIDs = []
    }

    func beginSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
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

    func toggleSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
        if let buffer = nearestBuffer(at: mapPoint, with: tolerance) {
            if buffer.isSelected {
                deselectBuffer(buffer)
            } else {
                selectBuffer(buffer)
            }
        }
    }

    func nearestBuffer(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> GPXBuffer? {
        let polyline = self.nearestPolyline(at: mapPoint, with: tolerance)
        return polyline.flatMap { _polylineDic[$0] }
    }

    func nearestPolyline(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) -> MKPolyline? {
        var nearest: MKPolyline?
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude
        for buffer in allBuffers.values {
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
        bufferLoop: for buffer in allBuffers.values {
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

    // MARK: - Zoom

    func zoom() {
        if selectedBufferIDs.isEmpty {
            zoomToAllBuffers()
        } else {
            zoomToSelected()
        }
    }

    func zoomToAllBuffers() {
        guard let mapView else { return }
        var zoomRect = MKMapRect.null

        for buffer in allBuffers.values {
            for polyline in buffer.polylines {
                zoomRect = zoomRect.union(polyline.boundingMapRect)
            }
        }
        if !zoomRect.isNull {
            Task {
                let padding: CGFloat = 10
                let edgePadding = NSEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
                mapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: true)
            }
        }
    }

    func zoomToSelected() {
        guard let mapView else { return }
        var zoomRect = MKMapRect.null

        for buffer in selectedBuffers {
            for polyline in buffer.polylines {
                zoomRect = zoomRect.union(polyline.boundingMapRect)
            }
        }
        if !zoomRect.isNull {
            Task {
                let padding: CGFloat = 10
                let edgePadding = NSEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
                mapView.setVisibleMapRect(zoomRect, edgePadding: edgePadding, animated: true)
            }
        }
    }
}

