//
//  Array
//  AppwiseCore
//
//  Created by David Jennes on 24/07/2018.
//

import CoreData
import Groot

extension Array: Insertable where Element: ManyInsertable & Insertable {
	public static func insert(from json: Any, in context: NSManagedObjectContext) throws -> [Element] {
		guard let jsonArray = json as? JSONArray else {
			throw InsertError.invalidJSON(json)
		}

		return (try Element.insertMany(from: jsonArray, in: context) as? [Element])
			.require(hint: "Insert result is not of type \([Element].self)")
	}

	public func inContext(_ context: NSManagedObjectContext) throws -> [Element] {
		return try compactMap { try $0.inContext(context) }
	}
}

extension Array: Importable {
	public func didImport(from data: Any, in context: ImportContext) throws {
		guard Element.self is Importable.Type || Element.self is ManyImportable.Type else { return }
		guard let data = data as? [Any] else { throw ImportError.dataIsIncorrectType }

		// if many importable, iterate over each item, and call the general function with all items
		if let array = self as? [ManyImportable],
			let type = Element.self as? ManyImportable.Type {
			for (importedData, importedItem) in zip(data, array) {
				try type.didImport(item: importedItem, from: importedData, in: context)
			}

			try type.didImport(items: array, from: data, in: context)

			// otherwise if items are importable, iterate over each item
		} else if let array = self as? [Importable] {
			for (importedData, importedItem) in zip(data, array) {
				try importedItem.didImport(from: importedData, in: context)
			}
		}
	}
}
