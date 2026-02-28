//
//  ActorLoggerTests.swift
//  HelloSwiftFrameworkTests
//
//  Created by Kyuhyun Park on 11/28/24.
//

import Foundation
import Testing
import MyLibrary

struct SimpleLoggerTests {

    @Test func test() async throws {
        let logger = SimpleLogger<Int>()

        logger.log(1)

        await Task {
            logger.log(2)
        }.value

        logger.log(3)

        #expect(logger.result() == [1, 2, 3])
    }

}
