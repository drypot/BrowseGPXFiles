//
//  Clipboard.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/12/26.
//

import Foundation
import MyLibrary

class Clipboard {
    public static let shared = Clipboard()

    public var gpxCopies: [GPX] = []

    private init() {}
}
