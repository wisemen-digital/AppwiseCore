//
//  Repository.swift
//  AppwiseCore
//
//  Created by David Jennes on 09/03/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Alamofire
import CoreData

public protocol ObjectListRepository {
	associatedtype ObjectType: NSManagedObject

	var context: NSManagedObjectContext { get }
	var fetchRequest: NSFetchRequest<ObjectType> { get }

	var frc: NSFetchedResultsController<ObjectType> { get }
	func refresh(then handler: @escaping (Result<[ObjectType]>) -> Void)
	func findOldItems() -> [ObjectType]
}

// MARK: - Default implementations

public extension ObjectListRepository {
	var frc: NSFetchedResultsController<ObjectType> {
		return NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
	}

	func refresh(then handler: @escaping (Result<[ObjectType]>) -> Void) {
		handler(.cancelled)
	}

	func findOldItems() -> [ObjectType] {
		return context.findOldItems(filter: fetchRequest.predicate)
	}
}

// MARK: - Helper properties

public extension ObjectListRepository {
	var firstObject: ObjectType? {
		let request = fetchRequest.then {
			$0.fetchLimit = 1
		}

		return try? context.fetch(request).first
	}

	var allObjects: [ObjectType] {
		(try? context.fetch(fetchRequest)) ?? []
	}

	var hasResults: Bool {
		numberOfResults > 0
	}

	var numberOfResults: Int {
		(try? context.count(for: fetchRequest)) ?? 0
	}
}
