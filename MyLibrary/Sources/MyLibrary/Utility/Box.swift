//
//  Box.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 4/18/25.
//

import Foundation

public final class Box<T>: Hashable {

    public var value: T

    public init(_ value: T) {
        self.value = value
    }

    public static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Box: CustomStringConvertible {
    public var description: String {
        String(describing: value)
    }
}

extension Box: Codable where T: Codable {
    public convenience init(from decoder: Decoder) throws {
        let value = try T(from: decoder)
        self.init(value)
    }

    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

public final class NSBox<T>: NSObject {

    public var value: T

    public init(_ value: T) {
        self.value = value
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? NSBox else { return false }
        return self === other
    }

    public override var hash: Int {
        return ObjectIdentifier(self).hashValue
    }

    public override var description: String {
        String(describing: value)
    }
}

extension NSBox: Codable where T: Codable {
    public convenience init(from decoder: Decoder) throws {
        let value = try T(from: decoder)
        self.init(value)
    }

    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
