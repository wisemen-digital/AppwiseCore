//
//  ManagedObjectContext.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CoreData

public extension NSManagedObjectContext {
	enum Error: Swift.Error {
		case entityNotFound
		case unsupportedIdentityAttributes
		case unableToCastObjectTo(type: NSManagedObject.Type)
	}

	/// Find the first object matching a given value, using the Groot unique key.
	///
	/// - parameter value: The value to match.
	///
	/// - returns: The found object or nil.
	func first<T: NSManagedObject>(value: Any) throws -> T? {
		let keys = T.entity().keysForUniquing
		guard keys.count == 1, let key = keys.first else {
			throw Error.unsupportedIdentityAttributes
		}

		return first(key: key, value: value)
	}

	/// Find the first object matching a given value, using a given key.
	///
	/// - parameter key: The key to search.
	/// - parameter value: The value to match.
	///
	/// - returns: The found object or nil.
	func first<T: NSManagedObject>(key: PartialKeyPath<T>, value: Any) -> T? {
		guard let keyPath = key._kvcKeyPathString else { return nil }
		return first(key: keyPath, value: value)
	}

	private func first<T: NSManagedObject>(key: String, value: Any) -> T? {
		let predicate = NSPredicate(format: "%K = %@", argumentArray: [key, value])
		return first(predicate: predicate)
	}

	/// Find the first object matching a given predicate and sorting.
	///
	/// - parameter sortDescriptor: The descriptor to sort against.
	/// - parameter predicate: The predicate to search with.
	///
	/// - returns: The found object or nil.
	func first<T: NSManagedObject>(sortDescriptor: NSSortDescriptor? = nil, predicate: NSPredicate? = nil) -> T? {
		T.fetchRequest()
		let request = T.fetchRequest(
			predicate: predicate,
			sortDescriptors: [sortDescriptor].compactMap { $0 },
			limit: 1
		)

		guard let result = try? fetch(request) else { return nil }
		return result.first
	}

	/// Convert an object from one context into an instance from this context.
	///
	/// - parameter item: The object to convert.
	///
	/// - returns: The converted object or nil.
	func inContext<T: NSManagedObject>(_ item: T) throws -> T {
		if item.objectID.isTemporaryID {
			try item.managedObjectContext?.obtainPermanentIDs(for: [item])
		}

		guard let result = object(with: item.objectID) as? T else {
			throw Error.unableToCastObjectTo(type: T.self)
		}
		return result
	}

	/// Find all the old unmodified objects in this context, matching a predicate.
	///
	/// - parameter filter: The predicate to match against.
	///
	/// - returns: A list of old objects.
	func findOldItems<T: NSManagedObject>(filter: NSPredicate? = nil) -> [T] {
		let request = T.fetchRequest(predicate: filter).then {
			$0.returnsObjectsAsFaults = true
			$0.includesPropertyValues = false
		}

		let newIDs = Set<NSManagedObjectID>(
			updatedObjects.compactMap { ($0 as? T)?.objectID } +
			insertedObjects.compactMap { ($0 as? T)?.objectID }
		)

		let fetched: [T] = (try? self.fetch(request)) ?? []
		return fetched.filter { !newIDs.contains($0.objectID) }
	}

	/// Specifies objects that should be removed from their persistent store when changes are committed.
	///
	/// - parameter items: A list of objects
	func delete<T: NSManagedObject>(_ items: [T]) {
		for item in items {
			delete(item)
		}
	}

	/// Delete all objects of a certain type, using a batch delete.
	///
	/// - parameter entity: The entity type to delete all instances of.
	/// - parameter resultType: The desired batch delete result type. (default:
	///                         `.resultTypeStatusOnly`)
	/// - returns: The result of the batch delete request.
	///
	/// - warning: This may not be directly visible in your current until it's
	///            sync'ed with the persistent store. You can use either
	///            `NSManagedObjectContext.reset()` or use the result of the batch
	///            request by setting the result type to `.resultTypeObjectIDs`.
	@discardableResult
	func removeAll<T: NSManagedObject>(of entity: T.Type, resultType: NSBatchDeleteRequestResultType = .resultTypeStatusOnly) throws -> NSBatchDeleteResult {
		let request: NSFetchRequest<NSFetchRequestResult> = T.fetchRequest()
		let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
		deleteRequest.resultType = resultType

		guard let result = try execute(deleteRequest) as? NSBatchDeleteResult else {
			fatalError("Must be a batch delete result")
		}
		return result
	}
}

fileprivate extension NSEntityDescription {
	var keysForUniquing: Set<String> {
		var keys = Set<String>()
		var entity: NSEntityDescription? = self

		while entity != nil {
			if let identity = entity?.userInfo?["identityAttributes"] as? String {
				identity.components(separatedBy: CharacterSet(charactersIn: " ,"))
					.filter { !$0.isEmpty }
					.forEach { keys.insert($0) }
			}

			entity = entity?.superentity
		}

		return keys
	}
}
