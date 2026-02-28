//
//  GPXParser.swift
//  BrowseGPXFiles
//
//  Created by drypot on 2024-04-03.
//

// 참고
// https://github.com/mmllr/GPXKit/blob/main/Sources/GPXKit/GPXFileParser.swift

import Foundation

public struct GPXParser {

    typealias XMLNode = BasicXMLParser.XMLNode
    
    public func parse(_ data: Data) throws -> GPX {
        let root = try BasicXMLParser().parse(data)
        return parse(rootNode: root)
    }
    
    private func parse(rootNode: XMLNode) -> GPX {
        var gpx = GPX()

        gpx.creator = rootNode.attributes["creator"] ?? ""
        gpx.version = rootNode.attributes["version"] ?? ""
        
        if let metadataNode = child(of: rootNode, tag: "metadata") {
            gpx.metadata.name = content(of: metadataNode, tag: "name")
            gpx.metadata.description = content(of: metadataNode, tag: "desc")
        }
        
        for waypointNode in children(of: rootNode, tag: "wpt") {
            let waypoint = parse(waypointNode: waypointNode)
            gpx.waypoints.append(waypoint)
        }
        
        for trackNode in children(of: rootNode, tag: "trk") {
            let track = parse(trackNode: trackNode)
            gpx.tracks.append(track)
        }
        
        return gpx
    }
    
    private func parse(waypointNode: XMLNode) -> GPXWaypoint {
        var waypoint = GPXWaypoint()
        waypoint.point = parse(pointNode: waypointNode)
        waypoint.name = content(of: waypointNode, tag: "name")
        waypoint.comment = content(of: waypointNode, tag: "cmt")
        waypoint.description = content(of: waypointNode, tag: "desc")
        waypoint.symbol = content(of: waypointNode, tag: "sym")
        waypoint.type = content(of: waypointNode, tag: "type")
        return waypoint
    }
    
    private func parse(trackNode: XMLNode) -> GPXTrack {
        var track = GPXTrack()
        track.name = content(of: trackNode, tag: "name")
        track.comment = content(of: trackNode, tag: "cmt")
        track.description = content(of: trackNode, tag: "desc")
        for segmentNode in children(of: trackNode, tag: "trkseg") {
            let segment = parse(segmentNode: segmentNode)
            track.segments.append(segment)
        }
        return track
    }
    
    private func parse(segmentNode: XMLNode) -> GPXSegment {
        var segment = GPXSegment()
        for pointNode in segmentNode.children {
            if pointNode.name != "trkpt" { continue }
            let p = parse(pointNode: pointNode)
            segment.points.append(p)
        }
        return segment
    }
    
    private func parse(pointNode: XMLNode) -> GPXPoint {
        var p = GPXPoint()
        p.latitude = Double(pointNode.attributes["lat"] ?? "") ?? 0.0
        p.longitude = Double(pointNode.attributes["lon"] ?? "")  ?? 0.0
        p.elevation = Double(content(of: pointNode, tag: "ele")) ?? 0.0
        return p
    }
    
    private func child(of node: XMLNode, tag: String) -> XMLNode? {
        node.children.first {
            $0.name.lowercased() == tag
        }
    }
    
    private func children(of node: XMLNode, tag: String) -> [XMLNode] {
        node.children.filter {
            $0.name.lowercased() == tag
        }
    }
    
    private func content(of node: XMLNode, tag: String) -> String {
        child(of: node, tag: tag)?.content ?? ""
    }
    
}
