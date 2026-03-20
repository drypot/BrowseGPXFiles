//
//  GPXExporterTests.swift
//  ModelTests
//
//  Created by Kyuhyun Park on 8/23/24.
//

import Foundation
import Testing
@testable import MyLibrary

struct GPXExporterTests {

    static let gpx: GPX = {
        let url = Bundle.module.resourceURL!.appending(path: "GPXTest/manual-multiple.gpx")
        return try! GPXParser().parse(contentOf: url)
    }()

    nonisolated(unsafe) static var exp: GPXExporter = {
        GPXExporter(gpx)
    }()

    @Test func testTrkseg() throws {
        let gpx = Self.gpx
        let exp = Self.exp
        let result = exp.makeSegmentTags(gpx.tracks[0].segments)
        let expected = """
            <trkseg>
            <trkpt lat="37.5323012" lon="127.0596635"><ele>0</ele></trkpt>
            <trkpt lat="37.5338156" lon="127.056756"><ele>0</ele></trkpt>
            </trkseg>
            <trkseg>
            <trkpt lat="37.5348451" lon="127.0529473"><ele>0</ele></trkpt>
            <trkpt lat="37.5365211" lon="127.0469928"><ele>0</ele></trkpt>
            <trkpt lat="37.5369805" lon="127.0454371"><ele>0</ele></trkpt>
            </trkseg>
            
            """
        #expect(result == expected)
    }
    
    @Test func testTrk() throws {
        let gpx = Self.gpx
        let exp = Self.exp
        let result = exp.makeTrackTags(gpx.tracks)
        let expected = """
            <trk>
            <trkseg>
            <trkpt lat="37.5323012" lon="127.0596635"><ele>0</ele></trkpt>
            <trkpt lat="37.5338156" lon="127.056756"><ele>0</ele></trkpt>
            </trkseg>
            <trkseg>
            <trkpt lat="37.5348451" lon="127.0529473"><ele>0</ele></trkpt>
            <trkpt lat="37.5365211" lon="127.0469928"><ele>0</ele></trkpt>
            <trkpt lat="37.5369805" lon="127.0454371"><ele>0</ele></trkpt>
            </trkseg>
            </trk>
            <trk>
            <trkseg>
            <trkpt lat="37.5323012" lon="127.0596635"><ele>0</ele></trkpt>
            <trkpt lat="37.5338156" lon="127.056756"><ele>0</ele></trkpt>
            <trkpt lat="37.5348451" lon="127.0529473"><ele>0</ele></trkpt>
            </trkseg>
            <trkseg>
            <trkpt lat="37.5365211" lon="127.0469928"><ele>0</ele></trkpt>
            <trkpt lat="37.5369805" lon="127.0454371"><ele>0</ele></trkpt>
            </trkseg>
            </trk>
            
            """
        #expect(result == expected)
    }
    
    @Test func testMetadata() throws {
        let exp = Self.exp
        let result = exp.makeMetadataTag()
        let expected = """
            <metadata>
            <name>name1</name>
            <desc>desc1</desc>
            </metadata>
            
            """
        #expect(result == expected)
    }
    
    @Test func testGPX() throws {
        let exp = Self.exp
        let result = exp.makeGPXTag(content: "<trk></trk>")
        let expected = """
            <?xml version="1.0" encoding="UTF-8"?>
            <gpx xmlns="http://www.topografix.com/GPX/1/1"
            creator="BrowseGPXFiles" version="1.1"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
            <trk></trk>
            </gpx>
            """
        #expect(result == expected)
    }
    
}
