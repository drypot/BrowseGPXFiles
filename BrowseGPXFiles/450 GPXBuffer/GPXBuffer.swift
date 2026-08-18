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
nonisolated final class GPXBuffer: Identifiable, Hashable {
    var url: URL { gpx.url }
    var name: String { gpx.name }
    var id: URL { gpx.url }

    private(set) var gpx: GPXFile

    private(set) var polylines: [MKPolyline]
    var isSelected = false
    
    init(gpx: GPXFile) {
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

    convenience init(contentOf url: URL) throws {
        let gpx = try GPXParser().parse(contentOf: url)
        self.init(gpx: gpx)
    }

    // MARK: - MapView

    @MainActor
    func updatePolylines(on mapView: MKMapView) {
        for polyline in polylines {
            if let renderer = mapView.renderer(for: polyline) as? MKPolylineRenderer {
                renderer.strokeColor = isSelected ? .red : .blue
            }
        }
    }

    @MainActor
    func addOverlays(on mapView: MKMapView) {
        mapView.addOverlays(polylines)
    }

    @MainActor
    func removeOverlays(on mapView: MKMapView) {
        mapView.removeOverlays(polylines)
    }

    // MARK: - Equatable, Hashable

    static func == (lhs: GPXBuffer, rhs: GPXBuffer) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
