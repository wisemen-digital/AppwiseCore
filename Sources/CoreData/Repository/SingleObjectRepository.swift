//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public protocol SingleObjectRepository {
	associatedtype ObjectType: NSManagedObject & _Identifiable

	var objectID: Identifier<ObjectType> { get }
	var context: NSManagedObjectContext { get }
	init(objectID: Identifier<ObjectType>, context: NSManagedObjectContext)

	var object: ObjectType? { get }
	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void)
}

public extension SingleObjectRepository {
	init(objectID: Identifier<ObjectType>) {
		self.init(objectID: objectID, context: DB.shared.view)
	}

	var object: ObjectType? {
		try? context.first(value: objectID.rawValue)
	}

	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void) {
		handler(.cancelled)
	}
}
