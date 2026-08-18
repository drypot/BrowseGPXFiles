//
//  Error.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 5/16/24.
//

import Foundation

enum LocalError: Error {
    case testing
    case general(String)
}

class ErrorLogger {
    private static let logger = SimpleLogger<String>()

    static func log(_ value: String) {
        print(value)
        logger.log(value)
    }

    static func log(_ error: any Error) {
        let value: String = error.localizedDescription
        log(value)
    }
    
    static func result() -> [String] {
        return logger.result()
    }

}
