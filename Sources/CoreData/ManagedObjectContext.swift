//
//  ManagedObjectContext.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CoreData
import SugarRecord

public extension NSManagedObjectContext {
	public enum Error: Swift.Error {
		case entityNotFound
		case unsupportedIdentityAttributes
		case unableToCastObjectTo(type: NSManagedObject.Type)
	}

	/// Find the first object matching a given value, using the Groot unique key.
	///
	/// - parameter value: The value to match.
	///
	/// - returns: The found object or nil.
	public func first<T: Entity>(value: Any) throws -> T? {
		guard let entity = T.self as? NSManagedObject.Type else { throw StorageError.invalidType }
		guard let description = NSEntityDescription.entity(forEntityName: entity.entityName, in: self) else {
			throw Error.entityNotFound
		}
		let keys = description.keysForUniquing
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
	public func first<T: Entity>(key: PartialKeyPath<T>, value: Any) -> T? {
		guard let keyPath = key._kvcKeyPathString else { return nil }
		return first(key: keyPath, value: value)
	}

	private func first<T: Entity>(key: String, value: Any) -> T? {
		let predicate = NSPredicate(format: "%K = %@", argumentArray: [key, value])
		return first(predicate: predicate)
	}

	/// Find the first object matching a given predicate and sorting.
	///
	/// - parameter sortDescriptor: The descriptor to sort against.
	/// - parameter predicate: The predicate to search with.
	///
	/// - returns: The found object or nil.
	public func first<T: Entity>(sortDescriptor: NSSortDescriptor? = nil, predicate: NSPredicate? = nil) -> T? {
		let request = FetchRequest<T>(self, sortDescriptor: sortDescriptor, predicate: predicate, fetchLimit: 1)

		guard let result = try? request.fetch() else { return nil }
		return result.first
	}

	/// Convert an object from one context into an instance from this context.
	///
	/// - parameter item: The object to convert.
	///
	/// - returns: The converted object or nil.
	public func inContext<T: NSManagedObject>(_ item: T) throws -> T {
		if item.objectID.isTemporaryID {
			try item.managedObjectContext?.obtainPermanentIDs(for: [item])
		}

		guard let result = try existingObject(with: item.objectID) as? T else {
			throw Error.unableToCastObjectTo(type: T.self)
		}
		return result
	}

	/// Find all the old unmodified objects in this context, matching a predicate.
	///
	/// - parameter filter: The predicate to match against.
	///
	/// - returns: A list of old objects.
	public func findOldItems<T: NSManagedObject>(filter: NSPredicate? = nil) throws -> [T] {
		let request = NSFetchRequest<T>(entityName: T.entityName).then {
			$0.predicate = filter
			$0.returnsObjectsAsFaults = true
			$0.includesPropertyValues = false
		}

		let newIDs = Set<NSManagedObjectID>(
			updatedObjects.compactMap { ($0 as? T)?.objectID } +
			insertedObjects.compactMap { ($0 as? T)?.objectID }
		)

		let fetched: [T] = try self.fetch(request)
		return fetched.filter { !newIDs.contains($0.objectID) }
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
