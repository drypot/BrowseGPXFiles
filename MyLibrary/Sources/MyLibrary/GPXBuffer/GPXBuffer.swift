//
//  GPXBuffer.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MapKit

@Observable
public final class GPXBuffer: Identifiable, Hashable {
    public private(set) var url: URL
    public private(set) var name: String

    private(set) var gpx: GPX
    private(set) var polylines: [MKPolyline] = []

    var isSelected = false

    public var id: URL { url }

    public init(url: URL, gpx: GPX) {
        self.url = url
        self.name = url.lastPathComponent
        self.gpx = gpx
        updatePolylines()
    }

//    convenience override init() {
//        self.init(GPX())
//    }

    // MARK: - Polyline

    func updatePolylines() {
        polylines.removeAll()
        for track in gpx.tracks {
            for segment in track.segments {
                let polyline = GPXUtility.makePolyline(from: segment)
                polylines.append(polyline)
            }
        }
    }

    // MARK: - NSObject

//    override func isEqual(_ object: Any?) -> Bool {
//        guard let other = object as? Self else { return false }
//        return self === other
//    }
//
//    override var hash: Int {
//        return ObjectIdentifier(self).hashValue
//    }
//
//    override var description: String {
//        String(describing: gpx)
//    }

    // MARK: - Comparable

//    static func < (lhs: GPXCache, rhs: GPXCache) -> Bool {
//        return lhs.filename < rhs.filename
//    }
//
//    @objc func compare(_ object: Any?) -> ComparisonResult {
//        guard let other = object as? GPXCache else { return .orderedSame }
//        if self < other {
//            return .orderedAscending
//        } else if self > other {
//            return .orderedDescending
//        } else {
//            return .orderedSame
//        }
//    }

    // MARK: - Equatable, Hashable

    public static func == (lhs: GPXBuffer, rhs: GPXBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct GPXBufferMaker {
    public func make(from url: URL) throws -> GPXBuffer {
        let gpx = try GPXUtility.makeGPX(from: url)
        return  GPXBuffer(url: url, gpx: gpx)
    }
}
