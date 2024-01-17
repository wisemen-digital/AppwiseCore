//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import AppwiseCoreCore
import CoreData

public protocol SingleObjectRepository {
	associatedtype ObjectType: NSFetchRequestResult, _Identifiable

	var objectID: Identifier<ObjectType> { get }
	var context: NSManagedObjectContext { get }
	var object: ObjectType? { get }

	init(objectID: Identifier<ObjectType>, context: NSManagedObjectContext)
	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void)
}

// MARK: - Default implementations

public extension SingleObjectRepository {
	init(objectID: Identifier<ObjectType>) {
		self.init(objectID: objectID, context: DB.shared.view)
	}

	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void) {
		assertionFailure("Forgot to implement refresh handler of repository \(Self.self).")
		handler(.failure(UnimplementedMethod()))
	}
}

// MARK: - Helper properties

public extension SingleObjectRepository where ObjectType: NSManagedObject {
	var object: ObjectType? {
		try? context.first(value: objectID.rawValue)
	}
}
