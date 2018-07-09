//
//  Insertable.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 6/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import CoreData
import Foundation
import Groot

/// The errors that can be thrown if
///
/// - invalidJSON: The JSON is invalid and can't be used for the given operation
/// - dataIsIncorrectType: The data used for import does not match the expected data type
/// - elementIsIncorrectType: The element type of a `Many` isn't `ManyImportable`
public enum InsertError: Error {
    case invalidJSON(Any)
    case dataIsIncorrectType
    case elementIsIncorrectType
}

/// Extra context information for handling an import operation
public struct ImportContext {
    /// The current managed object context
    public let moc: NSManagedObjectContext

    /// An extra context object, could for example be the `User` object related to this import
    public let object: Any?
}

/// Objects that can be inserted into a `NSManagedObjectContext` from a JSON object
public protocol Insertable {
    /// Insert an object of the receiver type in the given context using the received JSON
    ///
    /// - parameter json:    The JSON used to insert the object
    /// - parameter context: The context where the object will be inserted
    ///
    /// - throws: An `InsertError` If the JSON can't be inserted.
    ///
    /// - returns: The inserted object
    static func insert(from json: Any, in context: ImportContext) throws -> Self

    /// Handle the import of a single object
    ///
    /// - parameter json: The data object used to import (from JSON for example)
    /// - parameter context: The current import context
    func didImport(from json: Any, in context: ImportContext) throws
}

public extension Insertable {
    func didImport(from json: Any, in context: ImportContext) throws {
    }
}

/// Objects that can be bulk-inserted into a `NSManagedObjectContext` from a JSON array
public protocol ManyInsertable {

    /// Insert an array object of the receiver type in the given context using the received JSON array
    ///
    /// - parameter json:    The JSON used to insert the objects
    /// - parameter context: The context where the objects will be inserted
    ///
    /// - throws: An `InsertError` If the JSON can't be inserted.
    ///
    /// - returns: The inserted objects. Even tough they are `Any`, they must be the same Type as the receiver
    static func insertMany(from json: Any, in context: ImportContext) throws -> [Any]

    /// Handle the import of a single object
    ///
    /// - parameter item: The newly imported item
    /// - parameter json: The data object used to import (from JSON for example)
    /// - parameter context: The current import context
    static func didImport(item: Any, from json: Any, in context: ImportContext) throws

    /// Handle the import of a multiple objects
    ///
    /// - parameter items: The newly imported items
    /// - parameter json: The data object used to import (from JSON for example)
    /// - parameter context: The current import context
    static func didImport(items: [Any], from json: [Any], in context: ImportContext) throws
}

/// When a ManyInsertable is a Insertable too, the default behaviour is return an array built by calling `insert` to any element 
public extension ManyInsertable where Self: Insertable {
    static func insertMany(from json: Any, in context: ImportContext) throws -> [Any] {
        guard let array = json as? JSONArray else {
            throw InsertError.invalidJSON(json)
        }

        return array.compactMap { try? insert(from: $0, in: context) }
    }

	static func didImport(items: [Any], from json: [Any], in context: ImportContext) throws {
		for (item, data) in zip(items, json) {
			try Self.didImport(item: item, from: data, in: context)
		}
	}

    static func didImport(item: Any, from json: Any, in context: ImportContext) throws {
        if let item = item as? Insertable {
            try item.didImport(from: json, in: context)
        }
    }
}

/// Default implementation so that the user isn't obligated to implement the single-item import function
public extension ManyInsertable {
    static func didImport(item: Any, json: Any, context: ImportContext) throws {
    }
}
