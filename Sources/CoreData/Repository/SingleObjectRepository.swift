//
//  Repository.swift
//  AppwiseCore
//
//  Created by David Jennes on 09/03/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Alamofire
import CoreData

public protocol SingleObjectRepository {
	associatedtype ObjectType: NSManagedObject & Identifiable

	var objectID: Identifier<ObjectType> { get }
	var context: NSManagedObjectContext { get }
	init(objectID: Identifier<ObjectType>, context: NSManagedObjectContext)

	var object: ObjectType? { get }
	func refresh(then handler: @escaping (Result<ObjectType>) -> Void)
}

public extension SingleObjectRepository {
	init(objectID: Identifier<ObjectType>) {
		self.init(objectID: objectID, context: DB.shared.view)
	}

	var object: ObjectType? {
		return try? context.first(value: objectID.rawValue)
	}

	func refresh(then handler: @escaping (Result<ObjectType>) -> Void) {
		// empty implementation
	}
}
