//
//  TestUtil.swift
//  BrowseGPXFilesTests
//
//  Created by Kyuhyun Park on 8/11/26.
//

import Foundation
import Testing

final nonisolated class TestBundle {
    static private let bundle = Bundle(for: TestBundle.self)
    static let resourceURL = bundle.resourceURL!.appending(path: "TestResources")
}
