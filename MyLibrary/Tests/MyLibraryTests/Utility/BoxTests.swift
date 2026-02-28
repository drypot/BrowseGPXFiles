//
//  BoxTests.swift
//  ModelTests
//
//  Created by Kyuhyun Park on 4/18/25.
//

import Foundation
import Testing
import MyLibrary

struct BoxTests {

    @Test func testBoxInt() throws {
        let box = Box(10)
        let box2 = box

        #expect(box.value == 10)
        #expect(box.value == box2.value)

        box.value = 20

        #expect(box.value == 20)
        #expect(box.value == box2.value)

        #expect(box == box2)
        #expect(box === box2)
    }

    @Test func testBoxArray() throws {
        let box = Box([1, 2, 3])
        let box2 = box

        #expect(box.value == [1, 2, 3])
        #expect(box.value == box2.value)

        box.value.append(4)

        #expect(box.value == [1, 2, 3, 4])
        #expect(box.value == box2.value)

        #expect(box == box2)
        #expect(box === box2)
    }

}
