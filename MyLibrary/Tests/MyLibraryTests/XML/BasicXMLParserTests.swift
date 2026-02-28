//
//  BasicXMLParserTests.swift
//  ModelTests
//
//  Created by drypot on 2024-04-04.
//

import Foundation
import Testing
@testable import MyLibrary

struct BasicXMLParserTests {

    typealias XMLError = BasicXMLParser.XMLError

    nonisolated(unsafe) static let root: BasicXMLParser.XMLNode = {
        let data = Data(gpxSamplePlotaRouteShort.utf8)
        do {
            return try BasicXMLParser().parse(data)
        } catch {
            fatalError()
        }
    }()

    @Test func testRoot() throws {
        let node = Self.root
        #expect(node.name == "gpx")
        #expect(node.attributes["creator"] == "www.plotaroute.com")
        #expect(node.attributes["version"] == "1.1")
    }
    
    @Test func testMetadata() throws {
        let node = Self.root.children[0]
        #expect(node.name == "metadata")
        #expect(node.children[0].name == "desc")
        #expect(node.children[0].content == "Route created on plotaroute.com")
    }
    
    @Test func testTrack() throws {
        let node = Self.root.children[1]
        #expect(node.name == "trk")
        #expect(node.children[0].name == "name")
        #expect(node.children[0].content == "Sample01")
    }
    
    @Test func testTrackSegment() throws {
        let node = Self.root.children[1].children[1]
        #expect(node.name == "trkseg")

        let point1 = Self.root.children[1].children[1].children[0]
        #expect(point1.name == "trkpt")
        #expect(point1.attributes["lat"] == "37.5323012")
        #expect(point1.attributes["lon"] == "127.0596635")
        #expect(point1.children[0].name == "ele")
        #expect(point1.children[0].content == "15")

        let point2 = Self.root.children[1].children[1].children[1]
        #expect(point2.name == "trkpt")
        #expect(point2.attributes["lat"] == "37.5338156")
        #expect(point2.attributes["lon"] == "127.056756")
    }

    @Test func testNoContent() throws {
        let data = Data(gpxSampleNoContent.utf8)
        #expect(throws: XMLError.parsingError(0)) {
            try BasicXMLParser().parse(data)
        }
    }

    @Test func testBadFormat() throws {
        let data = Data(gpxSampleBad.utf8)
        #expect(throws: XMLError.parsingError(9)) {
            try BasicXMLParser().parse(data)
        }
    }

    @Test func testNoTrack() throws {
        let data = Data(gpxSampleNoTrack.utf8)
        let root = try BasicXMLParser().parse(data)
        #expect(root.name == "gpx")
        #expect(root.children.first?.name == nil)
    }
}
