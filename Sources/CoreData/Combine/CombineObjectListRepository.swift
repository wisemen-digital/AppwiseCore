//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Combine
import CoreData

public protocol CombineObjectListRepository {
	associatedtype ObjectType: NSManagedObject

	var context: NSManagedObjectContext { get }
	var fetchRequest: NSFetchRequest<ObjectType> { get }

	var frc: NSFetchedResultsController<ObjectType> { get }
	func refresh(then handler: @escaping (Result<[ObjectType], Error>) -> Void)
	func findOldItems() -> [ObjectType]
}

// MARK: - Default implementations

@available(iOS 13.0, *)
public extension CombineObjectListRepository {
	var frc: NSFetchedResultsController<ObjectType> {
		NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil
		)
	}

	func refresh() -> AnyPublisher<Result<ObjectType, Error>, Never> {
		Result.Publisher(.cancelled).eraseToAnyPublisher()
	}

	func findOldItems() -> [ObjectType] {
		context.findOldItems(filter: fetchRequest.predicate)
	}
}

// MARK: - Helper properties

@available(iOS 13.0, *)
public extension CombineObjectListRepository {
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

