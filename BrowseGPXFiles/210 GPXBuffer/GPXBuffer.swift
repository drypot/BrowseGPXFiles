//
//  GPXBuffer.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MapKit
import MyLibrary

@Observable
nonisolated public final class GPXBuffer: Identifiable, Hashable {
    public private(set) var gpx: GPX
    public private(set) var polylines: [MKPolyline] = []
    public var isSelected = false
    
    public var id: ObjectIdentifier { ObjectIdentifier(self) }
    public var name: String { gpx.name }
    public var url: URL? { gpx.url }

    public init(gpx: GPX) {
        self.gpx = gpx
        updatePolylines()
    }

    public convenience init(contentOf url: URL) throws {
        // print("processing: \(url.path)")
        let data = try Data(contentsOf: url)
        var gpx = try GPXParser().parse(data: data)
        gpx.url = url
        gpx.name = url.lastPathComponent
        self.init(gpx: gpx)
    }

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
