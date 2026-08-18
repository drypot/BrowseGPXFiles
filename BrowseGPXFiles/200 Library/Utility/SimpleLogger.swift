//
//  SimpleLogger.swift
//  HelloSwiftFrameworkTests
//
//  Created by Kyuhyun Park on 11/28/24.
//

import Foundation
import os

nonisolated struct SimpleLogger<T>: Sendable where T: Sendable {

    private let _log = OSAllocatedUnfairLock(initialState: [T]())

    init() { }

    func log(_ value: T) {
        _log.withLock { $0.append(value) }
    }

    func result() -> [T] {
        _log.withLock { $0 }
    }
    
}
