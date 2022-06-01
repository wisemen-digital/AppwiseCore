//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData
import Combine

@available(iOS 13.0, *)
public protocol CombineSingleObjectRepository {
	associatedtype ObjectType: NSManagedObject & Identifiable

	var objectID: Identifier<ObjectType> { get }
	var context: NSManagedObjectContext { get }
	init(objectID: Identifier<ObjectType>, context: NSManagedObjectContext)

	var object: ObjectType? { get }
	func refresh() -> AnyPublisher<Result<ObjectType, Error>, Never>
}

@available(iOS 13.0, *)
public extension CombineSingleObjectRepository {
	init(objectID: Identifier<ObjectType>) {
		self.init(objectID: objectID, context: DB.shared.view)
	}

	var object: ObjectType? {
		try? context.first(value: objectID.rawValue)
	}

	func refresh() -> AnyPublisher<Result<ObjectType, Error>, Never> {
		Result.Publisher(.cancelled).eraseToAnyPublisher()
	}
}
