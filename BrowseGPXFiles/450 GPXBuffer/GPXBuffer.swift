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
nonisolated public final class GPXBuffer: Identifiable, Hashable {
    public var url: URL { gpx.url }
    public var name: String { gpx.name }
    public var id: URL { gpx.url }

    public private(set) var gpx: GPXFile

    public private(set) var polylines: [MKPolyline]
    public var isSelected = false
    
    public init(gpx: GPXFile) {
        self.gpx = gpx

        var polylines: [MKPolyline] = []
        for track in gpx.tracks {
            for segment in track.segments {
                let polyline = GPXUtility.makePolyline(from: segment)
                polylines.append(polyline)
            }
        }
        self.polylines = polylines
    }

    public convenience init(contentOf url: URL) throws {
        let gpx = try GPXParser().parse(contentOf: url)
        self.init(gpx: gpx)
    }

    // MARK: - Equatable, Hashable

    public static func == (lhs: GPXBuffer, rhs: GPXBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
