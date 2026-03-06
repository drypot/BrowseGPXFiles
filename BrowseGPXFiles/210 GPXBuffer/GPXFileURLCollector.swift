//
//  GPXFileURLCollector.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation
import UniformTypeIdentifiers
import MyLibrary

public struct GPXFileURLCollector {
    public init() {}
    
    public func collectRecursively(from url: URL) throws -> [URL] {
        let fileManager = FileManager.default
        var results: [URL] = []

        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey, .contentTypeKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let values = try url.resourceValues(forKeys: keySet)
        if values.isRegularFile == true,
           let contentType = values.contentType,
           contentType.conforms(to: .gpx) {
            results.append(url)
        } else if values.isDirectory == true {
            guard let enumerator = fileManager.enumerator(at: url,
                                                          includingPropertiesForKeys: keys,
                                                          options: options) else { return results }
            for case let url as URL in enumerator {
                try autoreleasepool {
                    let values = try url.resourceValues(forKeys: keySet)
                    if values.isRegularFile == true,
                       let contentType = values.contentType,
                       contentType.conforms(to: .gpx) {
                        results.append(url)
                    }
                }
            }
        }

        return results
    }
}
