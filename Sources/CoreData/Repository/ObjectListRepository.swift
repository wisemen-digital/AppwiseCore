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
		// empty implementation
	}

	func findOldItems() -> [ObjectType] {
		return context.findOldItems(filter: fetchRequest.predicate)
	}
}
