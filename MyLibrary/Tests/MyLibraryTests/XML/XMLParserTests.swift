//
//  XMLParserTests.swift
//  ModelTests
//
//  Created by drypot on 2024-04-02.
//

import Foundation
import Testing
@testable import MyLibrary

struct XMLParserTests {

    static let plotaRouteShortData: Data = {
        let url = Bundle.module.resourceURL!.appending(path: "GPXTest/plotaroute-short.gpx")
        return try! Data(contentsOf: url)
    }()

    @Test func testXMLParserDidStartDocument() throws {
        let parser = XMLParser(data: Self.plotaRouteShortData)

        class Delegate: NSObject, XMLParserDelegate {
            let logger = SimpleLogger<String>()

            func parserDidStartDocument(_ parser: XMLParser) {
                logger.log("start: \(parser.lineNumber)")
            }
            
            func parserDidEndDocument(_ parser: XMLParser) {
                logger.log("end: \(parser.lineNumber)")
            }
        }
        
        let delegate = Delegate()
        parser.delegate = delegate
        parser.parse()

        #expect(delegate.logger.result() == [
            "start: 1",
            "end: 22"
        ])
    }
    
    @Test func testXMLParserHandlingElement() throws {
        let parser = XMLParser(data: Self.plotaRouteShortData)

        class Delegate: NSObject, XMLParserDelegate {
            let logger = SimpleLogger<String>()

            func parser(
                _ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]
            ) {
                logger.log(elementName)
            }
        }
        
        let delegate = Delegate()
        parser.delegate = delegate
        parser.parse()
        
        #expect(delegate.logger.result() == [
            "gpx", "metadata", "desc", "trk", "name", "trkseg", "trkpt", "ele", "time", "trkpt", "ele", "time"
        ])
    }
    
    @Test func testXMLParserHandlingAttributes() throws {
        let parser = XMLParser(data: Self.plotaRouteShortData)

        class Delegate: NSObject, XMLParserDelegate {
            let logger = SimpleLogger<String>()

            func parser(
                _ parser: XMLParser,
                didStartElement elementName: String,
                namespaceURI: String?,
                qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]
            ) {
                if elementName == "trkpt" {
                    logger.log("\(attributeDict["lat"]!)")
                }
            }
        }
        
        let delegate = Delegate()
        parser.delegate = delegate
        parser.parse()

        #expect(delegate.logger.result() == [
            "37.5323012",
            "37.5338156"
        ])
    }
    
    @Test func testXMLParserHandlingText() throws {
        let parser = XMLParser(data: Self.plotaRouteShortData)

        class Delegate: NSObject, XMLParserDelegate {
            let logger = SimpleLogger<String>()

            func parser(
                _ parser: XMLParser,
                foundCharacters string: String
            ) {
                let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed != "" {
                    logger.log(trimmed)
                }
            }
        }
        
        let delegate = Delegate()
        parser.delegate = delegate
        parser.parse()
        
        #expect(delegate.logger.result() == [
            "Route created on plotaroute.com",
            "Sample01",
            "15",
            "2024-04-01T00:00:00Z",
            "15",
            "2024-04-01T00:04:51Z"
        ])
    }
    
    @Test func testXMLParserHandlingError() throws {
        let url = Bundle.module.resourceURL!.appending(path: "GPXTest/bad.gpx")
        let data = try Data(contentsOf: url)
        let parser = XMLParser(data: data)

        class Delegate: NSObject, XMLParserDelegate {
            let logger = SimpleLogger<String>()

            func parser(
                _ parser: XMLParser,
                parseErrorOccurred parseError: Error
            ) {
                logger.log("error: \(parser.lineNumber)")
            }
        }
        
        let delegate = Delegate()
        parser.delegate = delegate
        parser.parse()
        
        #expect(delegate.logger.result() == [
            "error: 8"
        ])
    }
}
