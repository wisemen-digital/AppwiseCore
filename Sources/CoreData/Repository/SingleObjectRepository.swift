//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public protocol SingleObjectRepository {
	associatedtype ObjectType: NSFetchRequestResult, _Identifiable

	var objectID: Identifier<ObjectType> { get }
	var context: NSManagedObjectContext { get }
	init(objectID: Identifier<ObjectType>, context: NSManagedObjectContext)

	var object: ObjectType? { get }
	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void)

	@available(iOS 13.0, *)
	func refresh() async -> Result<ObjectType, Error>
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

@available(iOS 13.0, *)
public extension SingleObjectRepository {
	func refresh() async -> Result<ObjectType, Error> {
		await withCheckedContinuation { continuation in
			self.refresh { continuation.resume(returning: $0) }
		}
	}
}

// MARK: - Helper properties

public extension SingleObjectRepository where ObjectType: NSManagedObject {
	var object: ObjectType? {
		try? context.first(value: objectID.rawValue)
	}
}
