//
//  XML.swift
//  BrowseGPXFiles
//
//  Created by drypot on 2024-04-04.
//

// 참고
// https://github.com/mmllr/GPXKit/blob/main/Sources/GPXKit/BasicXMLParser.swift

import Foundation

public final class BasicXMLParser: NSObject, XMLParserDelegate {

    enum XMLError: Swift.Error, Equatable {
        case parsingError(Int)
    }

    public struct XMLNode {
        public var name: String
        public var attributes:[String: String]
        public var content: String
        public var children: [XMLNode]

        public init(name: String = "", attributes: [String : String] = [:], content: String = "", children: [XMLNode] = []) {
            self.name = name
            self.attributes = attributes
            self.content = content
            self.children = children
        }
    }

    private var stack = [XMLNode()]

    public func parse(contentOf url: URL) throws -> XMLNode {
        let data = try Data(contentsOf: url)
        return try parse(data: data)
    }
    
    public func parse(data: Data) throws -> XMLNode {
        let parser = XMLParser(data: data)
        parser.delegate = self
        let result = autoreleasepool {
            parser.parse()
        }
        if !result {
            throw XMLError.parsingError(parser.lineNumber)
        }
        let root = stack.first?.children.first ?? stack[0]
        return root
    }
    
    public func parser(_: XMLParser, didStartElement elementName: String, namespaceURI _: String?,
                qualifiedName _: String?, attributes attributeDict: [String: String] = [:]) {
        let newNode = XMLNode(name: elementName, attributes: attributeDict)
        stack.append(newNode)
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?,
                qualifiedName qName: String?) {
        stack[stack.count - 2].children.append(stack.last!)
        stack.removeLast()
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String ) {
        stack[stack.count - 1].content += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Swift.Error ) {
        print(parseError.localizedDescription)
    }
    
}
