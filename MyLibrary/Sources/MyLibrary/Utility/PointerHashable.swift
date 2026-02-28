//
//  PointerHashable.swift
//  BrowseGPXFiles
//
//  Created by Kyuhyun Park on 4/13/25.
//

protocol PointerHashable: AnyObject, Hashable {}

extension PointerHashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
