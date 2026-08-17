//
//  Clipboard.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/12/26.
//

import Foundation

class Clipboard {
    public static let shared = Clipboard()

    public var gpxCopies: [GPXFile] = []

    private init() {}
}
