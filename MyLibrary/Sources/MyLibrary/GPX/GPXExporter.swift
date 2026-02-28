//
//  GPXExporter.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 8/23/24.
//

import Foundation

// 참고 https://github.com/mmllr/GPXKit/blob/main/Sources/GPXKit/GPXExporter.swift

public struct GPXExporter {
    let gpx: GPX
    let creator: String

    public init(_ gpx: GPX, creator: String = "BrowseGPXFiles") {
        self.gpx = gpx
        self.creator = creator
    }
    
    public func makeXMLString() -> String {
        var content = ""
        content += makeMetadataTag()
        content += makeTrackTags(gpx.tracks)
        return makeGPXTag(content: content)
    }
    
    func makeGPXTag(content: String) -> String {
        return """
            <?xml version="1.0" encoding="UTF-8"?>
            <gpx xmlns="http://www.topografix.com/GPX/1/1"
            creator="\(creator)" version="1.1"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
            \(content)
            </gpx>
            """
    }
    
    func makeMetadataTag() -> String {
        var result = "<metadata>\n"
        if gpx.metadata.name.isEmpty == false {
            result += "<name>" + gpx.metadata.name + "</name>\n"
        }
        if gpx.metadata.description.isEmpty == false {
            result += "<desc>" + gpx.metadata.description + "</desc>\n"
        }
        result += "</metadata>\n"
        return result
    }
    
    func makeTrackTags(_ tracks: [GPXTrack]) -> String {
        var result = ""
        for track in tracks {
            result += "<trk>\n"
            result += makeSegmentTags(track.segments)
            result += "</trk>\n"
        }
        return result
    }
    
    func makeSegmentTags(_ segments: [GPXSegment]) -> String {
        var result = ""
        for segment in segments {
            result += "<trkseg>\n"
            for point in segment.points {
                result += "<trkpt "
                result += "lat=\"" + String(point.latitude) + "\" "
                result += "lon=\"" + String(point.longitude) + "\">"
                result += "<ele>0</ele></trkpt>\n"
            }
            result += "</trkseg>\n"
        }
        return result
    }
}
