//
//  Importable.swift
//  AppwiseCore
//
//  Created by David Jennes on 05/03/2018.
//  Copyright © 2018 Appwise. All rights reserved.
//

import AlamofireCoreData
import CoreData

public enum ImportError: Error {
	/// Triggered should the data used for import not match the expected data type
	case dataIsIncorrectType
	/// Triggered if the element type of a `Many` isn't `ManyImportable`
	case elementIsIncorrectType
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
	/// - parameter data: The data object used to import (from JSON for example)
	/// - parameter context: The current import context
	func didImport(data: Any, context: ImportContext) throws
}

/// Implement this protocol if you want to do some post-processing after the import
/// of multiple objects, for example remove some old items
public protocol ManyImportable {
	/// Handle the import of a single object
	///
	/// - parameter item: The newly imported item
	/// - parameter data: The data object used to import (from JSON for example)
	/// - parameter context: The current import context
	static func didImport(item: Any, data: Any, context: ImportContext) throws

	/// Handle the import of a multiple objects
	///
	/// - parameter items: The newly imported items
	/// - parameter data: The data object used to import (from JSON for example)
	/// - parameter context: The current import context
	static func didImport(items: [Any], data: [Any], context: ImportContext) throws
}

/// Default implementation so that the user isn't obligated to implement the single-item import function
public extension ManyImportable {
	static func didImport(item: Any, data: Any, context: ImportContext) throws {
	}
}

/// Default implementation where an entity is both `Importable` and `ManyImportable`, where it'll try
/// to call `didImport` for each item by default
public extension ManyImportable where Self: Importable {
	static func didImport(item: Any, data: Any, context: ImportContext) throws {
		if let item = item as? Importable {
			try item.didImport(data: data, context: context)
		}
	}
}

// Conform Many-type to importable

extension Many: Importable {
	public func didImport(data: Any, context: ImportContext) throws {
		guard Element.self is Importable.Type || Element.self is ManyImportable.Type else { return }
		guard let data = data as? [Any] else { throw ImportError.dataIsIncorrectType }

		// if many importable, iterate over each item, and call the general function with all items
		if let array = self.array as? [ManyImportable],
			let type = Element.self as? ManyImportable.Type {

			for (importedData, importedItem) in zip(data, array) {
				try type.didImport(item: importedItem, data: importedData, context: context)
			}

			try type.didImport(items: array, data: data, context: context)

			// otherwise if items are importable, iterate over each item
		} else if let array = self.array as? [Importable] {
			for (importedData, importedItem) in zip(data, array) {
				try importedItem.didImport(data: importedData, context: context)
			}
		}
	}
}
