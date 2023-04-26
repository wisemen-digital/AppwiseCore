//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import CoreData

public protocol SingleObjectRepository {
	associatedtype ObjectType: NSFetchRequestResult, _Identifiable

	var objectID: Identifier<ObjectType> { get }
	var context: NSManagedObjectContext { get }
	init(objectID: Identifier<ObjectType>, context: NSManagedObjectContext)

	var object: ObjectType? { get }
	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void)
}

// MARK: - Default implementations

public extension SingleObjectRepository {
	init(objectID: Identifier<ObjectType>) {
		self.init(objectID: objectID, context: DB.shared.view)
	}

	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void) {
		handler(.cancelled)
	}
}

// MARK: - Helper properties

public extension SingleObjectRepository where ObjectType: NSManagedObject {
	var object: ObjectType? {
		try? context.first(value: objectID.rawValue)
	}
}
