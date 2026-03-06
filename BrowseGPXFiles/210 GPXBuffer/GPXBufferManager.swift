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

    public private(set) var bufferSet: Set<GPXBuffer> = []

    public private(set) var sortedBuffers: [GPXBuffer] = []
//    private var bufferDic: [URL: GPXBuffer] = [:]

    public private(set) var polylineToBufferDic: [MKPolyline: GPXBuffer] = [:]

    public var selectedBuffers: Set<GPXBuffer> = []

    public var addedBuffers: [GPXBuffer] = []
    public var removedBuffers: [GPXBuffer] = []
    public var selectionChangedBuffers: [GPXBuffer] = []

    public init() {}

    public func loadGPXFiles(from url: URL) async throws {
        var tmpBuffers: [GPXBuffer] = []

        // TODO: 중복 파일 임포트 방지. 먼 훗날에.
        for url in try GPXFileURLCollector().collectRecursively(from: url) {
            //print("loading: \(url.absoluteString)")
            let buffer = try GPXBufferMaker().make(from: url)
            tmpBuffers.append(buffer)
        }

        await MainActor.run {
            //        undoManager?.disableUndoRegistration()
            self.addBuffers(tmpBuffers)
            //        undoManager?.enableUndoRegistration()

            //        buffers.append(buffer)
            //        bufferDic[url] = buffer
        }
    }

    public func flushUpdated() {
        addedBuffers.removeAll()
        removedBuffers.removeAll()
        selectionChangedBuffers.removeAll()
    }

    // MARK: - Insert, Delete

    func addBuffers(_ buffers: [GPXBuffer]) {
//        undoManager?.registerUndo(withTarget: self) {
//            $0.removeGPXCaches(buffers)
//        }
        bufferSet.formUnion(buffers)
        addedBuffers.append(contentsOf: buffers)
        for buffer in buffers {
            for polyline in buffer.polylines {
                polylineToBufferDic[polyline] = buffer
            }
        }
        self.sortedBuffers = Array(bufferSet).sorted { $0.name < $1.name }
    }

    func removeBuffers(_ buffers: [GPXBuffer]) {
//        undoManager?.registerUndo(withTarget: self) {
//            $0.addGPXCaches(buffers)
//        }
        bufferSet.subtract(buffers)
        removedBuffers.append(contentsOf: buffers)
        for buffer in buffers {
            for polyline in buffer.polylines {
                polylineToBufferDic.removeValue(forKey: polyline)
            }
        }
    }

    public func removeSelectedBuffers() {
        let selectedBuffers = bufferSet.filter { $0.isSelected }
        if !selectedBuffers.isEmpty {
            removeBuffers(Array(selectedBuffers))
        }
    }

    // MARK: - Select

    public func beginSelection(at mapPoint: MKMapPoint, with tolerance: CLLocationDistance) {
        if let buffer = nearestGPX(at: mapPoint, with: tolerance) {
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
        if let buffer = nearestGPX(at: mapPoint, with: tolerance) {
            if buffer.isSelected {
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
        for buffer in bufferSet {
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

    public func selectAllBuffers() {
        for buffer in bufferSet {
            if !buffer.isSelected {
                selectBuffer(buffer)
            }
        }
    }

    public func deselectAllBuffers() {
        for buffer in bufferSet {
            if buffer.isSelected {
                deselectBuffer(buffer)
            }
        }
    }

    // MARK: - Select Core

    func selectBuffer(_ buffer: GPXBuffer) {
//        undoManager?.registerUndo(withTarget: self) {
//            $0.deselectGPXCache(buffer)
//        }
        buffer.isSelected = true
        selectionChangedBuffers.append(buffer)
    }

    func deselectBuffer(_ buffer: GPXBuffer) {
//        undoManager?.registerUndo(withTarget: self) {
//            $0.selectGPXCache(buffer)
//        }
        buffer.isSelected = false
        selectionChangedBuffers.append(buffer)
    }

}

