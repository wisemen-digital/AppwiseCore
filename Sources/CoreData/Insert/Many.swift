//
//  Many.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 7/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import CoreData
import Foundation
import Groot

/// An `Array` replacement which can just contains `ManyInsertable` instances. 
/// It implements `Insertable` so it can be used to insert-serialize array responses using Alamofire.
/// It can be used in the same way that `Array` exception mutability. Anyway, if you need to access the raw `Array` version of this class, you can use the `array` property.
public struct Many<Element: ManyInsertable> {
    /// The array representation of the receiver
    public fileprivate(set) var array: [Element]
    fileprivate init(_ array: [Element]) {
        self.array = array
    }
}

extension Many: Insertable {
    public static func insert(from json: Any, in context: ImportContext) throws -> Many<Element> {
        guard let jsonArray = json as? JSONArray else {
            throw InsertError.invalidJSON(json)
        }

		let array = (try Element.insertMany(from: jsonArray, in: context) as? [Element])
			.require(hint: "Insert result is not of type \([Element].self)")
        return Many(array)
    }

    public func didImport(from json: Any, in context: ImportContext) throws {
        guard let jsonArray = json as? JSONArray else {
            throw InsertError.invalidJSON(json)
        }

        for (item, importedData) in zip(array, jsonArray) {
            try Element.didImport(item: item, json: importedData, context: context)
        }
        try Element.didImport(items: array, from: jsonArray, in: context)
    }
}

// MARK: Array protocols
extension Many: MutableCollection {
    public var startIndex: Int {
        return array.startIndex
    }

    public var endIndex: Int {
        return array.endIndex
    }

    public subscript(position: Int) -> Element {
        get {
            return array[position]
        }
        set {
            array[position] = newValue
        }
    }

    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        get {
            return array[bounds]
        }
        set {
            array[bounds] = newValue
        }
    }

    public func index(after index: Int) -> Int {
        return array.index(after: index)
    }
}

extension Many: RangeReplaceableCollection {
    public mutating func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C: Collection, C.Iterator.Element == Element {
        self.array.replaceSubrange(subrange, with: newElements)
    }

    public init() {
        self.init([])
    }
}

extension Many: ExpressibleByArrayLiteral {
    public init(arrayLiteral: Element...) {
        self.init(arrayLiteral)
    }
}

extension Many: CustomReflectable {
    public var customMirror: Mirror {
        return array.customMirror
    }
}

extension Many: RandomAccessCollection {
    public typealias SubSequence = Array<Element>.SubSequence
    public typealias Indices = Array<Element>.Indices
}

extension Many: CustomDebugStringConvertible {
    public var debugDescription: String {
        return array.debugDescription
    }
}

extension Many: CustomStringConvertible {
    public var description: String {
        return array.description
    }
}
