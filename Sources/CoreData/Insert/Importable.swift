//
//  Importable.swift
//  AppwiseCore
//
//  Created by David Jennes on 05/03/2018.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CoreData

/// The errors that can be thrown if
///
/// - dataIsIncorrectType: The data used for import does not match the expected data type
public enum ImportError: Error {
	case dataIsIncorrectType
}

/// Extra context information for handling an import operation
public struct ImportContext {
	/// The current managed object context
	public let moc: NSManagedObjectContext

	/// An extra context object, could for example be the `User` object related to this import
	public let object: Any?
}

/// Implement this protocol if you want to do some post-processing after the import
/// of a single object, for example clean up some relationships or calculete some fields
public protocol Importable {
	/// Handle the import of a single object
	///
	/// - parameter json: The data object used to import (from JSON for example)
	/// - parameter context: The current import context
	func didImport(from json: Any, in context: ImportContext) throws
}

/// Implement this protocol if you want to do some post-processing after the import
/// of multiple objects, for example remove some old items
public protocol ManyImportable {
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

/// Default implementation so that the user isn't obligated to implement the single-item import function
public extension ManyImportable {
	static func didImport(item: Any, from data: Any, in context: ImportContext) throws {
	}
}

/// Default implementation where an entity is both `Importable` and `ManyImportable`, where it'll try
/// to call `didImport` for each item by default
public extension ManyImportable where Self: Importable {
	static func didImport(item: Any, from data: Any, in context: ImportContext) throws {
		if let item = item as? Importable {
			try item.didImport(from: data, in: context)
		}
	}
}
