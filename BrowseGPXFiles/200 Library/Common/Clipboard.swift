//
//  Clipboard.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/12/26.
//

import Foundation

class Clipboard {
    static let shared = Clipboard()

    var gpxCopies: [GPXFile] = []

    private init() {}
}
