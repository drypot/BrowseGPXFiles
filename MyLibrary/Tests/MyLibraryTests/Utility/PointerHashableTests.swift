//
//  PointerHashableTests.swift
//  ModelTests
//
//  Created by Kyuhyun Park on 4/13/25.
//

import Foundation
import Testing
@testable import MyLibrary

struct PointerHashableTests {

    @Test func testValueHashable() throws {

        class ClassA: Equatable, Hashable {
            var id: Int

            init(id: Int) {
                self.id = id
            }

            static func == (lhs: ClassA, rhs: ClassA) -> Bool {
                return lhs.id == rhs.id
            }

            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
        }

        let p1 = ClassA(id: 10)
        let p2 = ClassA(id: 10)
        let p3 = p1

        #expect(p1 == p2)
        #expect(p1 == p3)
    }

    @Test func testPointerHashable() throws {

        class ClassA: PointerHashable {
            var id: Int
            init(id: Int) {
                self.id = id
            }
        }

        let p1 = ClassA(id: 10)
        let p2 = ClassA(id: 10)
        let p3 = p1

        #expect(p1 != p2)
        #expect(p1 == p3)
    }

}
