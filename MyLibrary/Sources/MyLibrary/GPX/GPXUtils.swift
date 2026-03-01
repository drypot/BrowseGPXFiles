//
//  GPXUtils.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 8/20/24.
//

import Foundation
import MapKit

public enum GPXUtils {

    public static func makeGPX(from url: URL) throws -> GPX {
        let data = try Data(contentsOf: url)
        return try makeGPX(from: data)
    }

    public static func makeGPX(from data: Data) throws -> GPX {
        return try GPXParser().parse(data: data)
    }

    public static func makeData(from gpx: GPX) throws -> Data {
        let xmlString = GPXExporter(gpx).makeXMLString()
        return Data(xmlString.utf8)
    }

    public static func makeGPXSegment(from polyline: MKPolyline) -> GPXSegment {
        let segment = GPXSegment()
        let count = polyline.pointCount
        let pointer = polyline.points()
        for i in 0..<count {
            let c = pointer[i].coordinate
            let point = GPXPoint(latitude: c.latitude, longitude: c.longitude, elevation: 0)
            segment.points.append(point)
        }
        return segment
    }

    public static func makeGPXTracks(from polylines: Set<MKPolyline>) -> [GPXTrack] {
        var tracks = [GPXTrack]()
        for polyline in polylines {
            let track = GPXTrack()
            let segment = Self.makeGPXSegment(from: polyline)
            track.segments.append(segment)
            tracks.append(track)
        }
        return tracks
    }

    public static func makePolyline(from gpxSegment: GPXSegment) -> MKPolyline {
        let points = gpxSegment.points.map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
        return MKPolyline(coordinates: points, count: points.count)
    }

    public static func makePolylines(from gpxData: Data) throws -> [MKPolyline] {
        var polylines: [MKPolyline] = []
        let gpx = try GPXUtils.makeGPX(from: gpxData)
        for track in gpx.tracks {
            for segment in track.segments {
                polylines.append(self.makePolyline(from: segment))
            }
        }
        return polylines
    }

    public static func makePolylines(from urls: [URL]) async throws -> [MKPolyline] {
        var polylines: [MKPolyline] = []
        let items = try FileURLCollector().collectRecursively(from: urls)
        for url in items {
            let gpx = try GPXUtils.makeGPX(from: url)
            for track in gpx.tracks {
                for segment in track.segments {
                    polylines.append(self.makePolyline(from: segment))
                }
            }
        }
        return polylines
    }

    public static func calcDistance(from point: MKMapPoint, to polyline: MKPolyline) -> CLLocationDistance {
        var minDistance: CLLocationDistance = .greatestFiniteMagnitude

        let points = polyline.points()
        let pointCount = polyline.pointCount

        for i in 0 ..< pointCount - 1 {
            let line = MKMapLine(start: points[i], end: points[i + 1])
            let distance = calcDistance(from: point, to: line)
            minDistance = min(minDistance, distance)
        }

        return minDistance
    }

    public static func calcDistance(from point: MKMapPoint, to line: MKMapLine) -> CLLocationDistance {
        let x0 = point.x
        let y0 = point.y
        let start = line.start
        let end = line.end
        let x1 = start.x
        let y1 = start.y
        let x2 = end.x
        let y2 = end.y

        let dx = x2 - x1
        let dy = y2 - y1

        if dx == 0 && dy == 0 {
            // start and end are the same
            return start.distance(to: point)
        }

        // Project point onto the line segment
        let t = ((x0 - x1) * dx + (y0 - y1) * dy) / (dx * dx + dy * dy)

        if t < 0 {
            // Closest to start
            return start.distance(to: point)
        } else if t > 1 {
            // Closest to end
            return end.distance(to: point)
        } else {
            // Closest to the line segment
            let projection = MKMapPoint(x: x1 + t * dx, y: y1 + t * dy)
            return projection.distance(to: point)
        }
    }

}

public struct MKMapLine: Sendable {
    var start: MKMapPoint
    var end: MKMapPoint
}
