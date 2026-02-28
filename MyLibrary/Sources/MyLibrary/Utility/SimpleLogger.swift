//
//  SimpleLogger.swift
//  HelloSwiftFrameworkTests
//
//  Created by Kyuhyun Park on 11/28/24.
//

import Foundation
import os

public struct SimpleLogger<T>: Sendable where T: Sendable {

    private let _log = OSAllocatedUnfairLock(initialState: [T]())

    public init() { }

    public func log(_ value: T) {
        _log.withLock { $0.append(value) }
    }

    public func result() -> [T] {
        _log.withLock { $0 }
    }
    
}
