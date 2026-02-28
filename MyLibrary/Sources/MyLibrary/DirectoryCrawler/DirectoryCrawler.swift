//
//  DirectoryCrawler.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 2/28/26.
//

import Foundation

public class Folder {
    public var name: String
    public var url: URL
    public var folders: [Folder]?

    public init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }
}

public struct DirectoryCrawler {
    public init() {}

    public func collectFiles(from url: URL) throws -> [URL] {
        let fileManager = FileManager.default
        var results: [URL] = []

        let keys: [URLResourceKey] = [.isRegularFileKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        let items = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: keys,
            options: options
        )

        for item in items {
            try autoreleasepool {
                let values = try item.resourceValues(forKeys: keySet)
                if values.isRegularFile == true {
                    results.append(item)
                }
            }
        }

        return results
    }

    public func collectFilesRecursively(from urls: [URL]) throws -> [URL] {
        let fileManager = FileManager.default
        var results: [URL] = []

        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        for url in urls {
            let values = try url.resourceValues(forKeys: keySet)
            if values.isRegularFile == true {
                results.append(url)
            } else if values.isDirectory == true {
                guard let enumerator = fileManager.enumerator(
                    at: url,
                    includingPropertiesForKeys: keys,
                    options: options
                ) else { continue }

                for case let item as URL in enumerator {
                    try autoreleasepool {
                        let values = try item.resourceValues(forKeys: keySet)
                        if values.isRegularFile == true {
                            results.append(item)
                        }
                    }
                }
            }
        }

        return results
    }

    public func collectFilesRecursively(from url: URL) throws -> [URL] {
        return try collectFilesRecursively(from: [url])
    }

    public func buildFolderTree(from url: URL) throws -> Folder {
        let keys: [URLResourceKey] = [.isDirectoryKey]
        let keySet = Set(keys)
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles]

        func buildFolder(from url: URL) throws -> Folder {
            let fileManager = FileManager.default
            let folder = Folder(url: url)

            let items = try fileManager.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: keys,
                options: options
            )

            for item in items {
                try autoreleasepool {
                    let values = try item.resourceValues(forKeys: keySet)
                    if values.isDirectory == true {
                        let child = try buildFolder(from: item)
                        if folder.folders == nil {
                            folder.folders = [child]
                        } else {
                            folder.folders!.append(child)
                        }
                    }
                }
            }

            return folder
        }

        return try buildFolder(from: url)
    }
}
