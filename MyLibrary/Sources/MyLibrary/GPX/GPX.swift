//
//  GPX.swift
//  BrowseGPXFiles
//
//  Created by drypot on 2023-12-28.
//

import Foundation
import MapKit

// 참고
// https://github.com/mmllr/GPXKit/blob/main/Sources/GPXKit/Coordinate.swift

public struct GPX: Codable, Sendable {
    public var url: URL?
    public var name: String = ""

    public var creator: String = ""
    public var version: String = ""
    public var metadata: GPXMetadata = .init()
    public var waypoints: [GPXWaypoint] = []
    //public var routes: [GPXRoute]
    public var tracks: [GPXTrack] = []

    public init() {}
}

public struct GPXMetadata: Codable, Sendable {
    public var name: String = ""
    public var description: String = ""
    //public var author
    //public var copyright
    //public var link
    //public var time
    //public var keywords: String?
    //public var bounds:

    public init() {}
}

public struct GPXWaypoint: Codable, Sendable {
    public var point: GPXPoint = GPXPoint()

    //public var time
    //public var magvar
    //public var geoidheight

    public var name: String = ""
    public var comment: String = ""
    public var description: String = ""
    //public var source
    //public var link
    public var symbol: String = ""
    public var type: String = ""

    //public var fix
    //public var satellites
    //public var hdop
    //public var vdop
    //public var pdop
    //public var ageofdgpsdata
    //public var dgpsid

    public init() {}
}

public struct GPXTrack: Codable, Sendable {
    public var name: String = ""
    public var comment: String = ""
    public var description: String = ""
    //public var source: String?
    //public var link
    //public var number: Int?
    //public var type: String?
    public var segments: [GPXSegment] = []

    public init() {}
}

public struct GPXSegment: Codable, Sendable {
    public var points: [GPXPoint] = []

    public init() {}
}

public struct GPXPoint: Codable, Sendable {
    public var latitude = 0.0
    public var longitude = 0.0
    public var elevation = 0.0

    public init(latitude: Double = 0.0, longitude: Double = 0.0, elevation: Double = 0.0) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
    }
    
    public func almostEqual(_ target: Self) -> Bool {
        (self.latitude - target.latitude).magnitude < 0.000001 &&
        (self.longitude - target.longitude).magnitude < 0.000001 &&
        (self.elevation - target.elevation).magnitude < 0.00001
    }
}
