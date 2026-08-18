//
//  GPXFile.swift
//  BrowseGPXFiles
//
//  Created by drypot on 2023-12-28.
//

import Foundation
import MapKit
import CoreTransferable

// 참고
// https://www.topografix.com/gpx.asp
// https://www.topografix.com/GPX/1/1/
// https://github.com/mmllr/GPXKit/blob/main/Sources/GPXKit/Coordinate.swift

nonisolated struct GPXFile: Codable, Sendable, Transferable {
    var url: URL
    var name: String

    var creator: String = ""
    var version: String = ""

    var metadata: GPXMetadata = .init()
    var waypoints: [GPXWaypoint] = []
    //var routes: [GPXRoute]
    var tracks: [GPXTrack] = []

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .gpxInternal)
    }
}

nonisolated struct GPXMetadata: Codable, Sendable {
    var name: String = ""
    var description: String = ""
    //var author
    //var copyright
    //var link
    //var time
    //var keywords: String?
    //var bounds:

    init() {}
}

nonisolated struct GPXWaypoint: Codable, Sendable {
    var point: GPXPoint = GPXPoint()

    //var time
    //var magvar
    //var geoidheight

    var name: String = ""
    var comment: String = ""
    var description: String = ""
    //var source
    //var link
    var symbol: String = ""
    var type: String = ""

    //var fix
    //var satellites
    //var hdop
    //var vdop
    //var pdop
    //var ageofdgpsdata
    //var dgpsid

    init() {}
}

nonisolated struct GPXTrack: Codable, Sendable {
    var name: String = ""
    var comment: String = ""
    var description: String = ""
    //var source: String?
    //var link
    //var number: Int?
    //var type: String?
    var segments: [GPXSegment] = []

    init() {}
}

nonisolated struct GPXSegment: Codable, Sendable {
    var points: [GPXPoint] = []

    init() {}
}

nonisolated struct GPXPoint: Codable, Sendable {
    var latitude = 0.0
    var longitude = 0.0
    var elevation = 0.0

    init(latitude: Double = 0.0, longitude: Double = 0.0, elevation: Double = 0.0) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }
    
    func almostEqual(_ target: Self) -> Bool {
        (self.latitude - target.latitude).magnitude < 0.000001 &&
        (self.longitude - target.longitude).magnitude < 0.000001 &&
        (self.elevation - target.elevation).magnitude < 0.00001
    }
}
