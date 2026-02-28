//
//  Error.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 5/16/24.
//

import Foundation

public enum LocalError: Error {
    case testing
    case general(String)
}

public class ErrorLogger {
    private static let logger = SimpleLogger<String>()

    public static func log(_ value: String) {
        print(value)
        logger.log(value)
    }

    public static func log(_ error: any Error) {
        let value: String = error.localizedDescription
        log(value)
    }
    
    public static func result() -> [String] {
        return logger.result()
    }

}
