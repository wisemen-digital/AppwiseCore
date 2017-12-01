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
	enum Error: Swift.Error {
		case entityNotFound
		case unsupportedIdentityAttributes
		case unableToCastObject(to: Any)
	}
	
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
	
	public func first<T: Entity>(key: String, value: Any) -> T? {
		let predicate = NSPredicate(format: "%K = %@", argumentArray: [key, value])
		return first(predicate: predicate)
	}
	
	public func first<T: Entity>(sortDescriptor: NSSortDescriptor? = nil, predicate: NSPredicate? = nil) -> T? {
		let request = FetchRequest<T>(self, sortDescriptor: sortDescriptor, predicate: predicate, fetchLimit: 1)
		
		guard let result = try? request.fetch() else { return nil }
		return result.first
	}
	
	public func inContext<T: NSManagedObject>(_ item: T) throws -> T {
		if item.objectID.isTemporaryID {
			try item.managedObjectContext?.obtainPermanentIDs(for: [item])
		}
		
		guard let result = try existingObject(with: item.objectID) as? T else {
			throw Error.unableToCastObject(to: T.self)
		}
		return result
	}
	
	public func findOldItems<T: NSManagedObject>(filter: NSPredicate? = nil) throws -> [T] {
		let request = NSFetchRequest<T>(entityName: T.entityName)
		
		request.predicate = filter
		request.returnsObjectsAsFaults = true
		request.includesPropertyValues = false
		
		return (try self.fetch(request)).filter({
			!self.updatedObjects.contains($0) && !insertedObjects.contains($0)
		})
	}
}

extension NSEntityDescription {
	fileprivate var keysForUniquing: Set<String> {
		var keys = Set<String>()
		var entity: NSEntityDescription? = self
		
		while (entity != nil) {
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
