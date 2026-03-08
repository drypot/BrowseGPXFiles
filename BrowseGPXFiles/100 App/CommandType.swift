//
//  CommandType.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 3/7/26.
//

import Foundation
import SwiftUI

enum CommandType {
    case none
    case importFolders, importRecent
    case zoomIn, zoomOut, zoomToFit
}

struct runCommandKey: FocusedValueKey {
    typealias Value = (CommandType) -> Void
}

extension FocusedValues {
    var runCommand: runCommandKey.Value? {
        get { self[runCommandKey.self] }
        set { self[runCommandKey.self] = newValue }
    }
}
