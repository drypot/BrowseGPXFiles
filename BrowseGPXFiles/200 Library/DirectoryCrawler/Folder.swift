//
//  Folder.swift
//  MyLibrary
//
//  Created by Kyuhyun Park on 3/1/26.
//

import Foundation

nonisolated final class Folder: Identifiable, Comparable, Hashable {
    var url: URL
    var name: String
    var folders: [Folder]?

    var id: URL { url }

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
    }

    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.id == rhs.id
    }

    static func < (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.name < rhs.name
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
