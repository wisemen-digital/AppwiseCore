//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public extension NSFetchRequestResult where Self: NSManagedObject {
	/// Returns a fetch request for this object, using the parameters given as its properties.
	static func fetchRequest(
		predicate: NSPredicate? = nil,
		sortDescriptors: [NSSortDescriptor] = [],
		limit: Int? = nil,
		offset: Int? = nil,
		batchSize: Int? = nil,
		relationshipKeyPathsForPrefetching: [String] = []
	) -> NSFetchRequest<Self> {
		NSFetchRequest<Self>(entityName: entity().name ?? "").then {
			$0.predicate = predicate
			$0.sortDescriptors = sortDescriptors
			$0.fetchLimit = limit ?? $0.fetchLimit
			$0.fetchOffset = offset ?? $0.fetchOffset
			$0.fetchBatchSize = batchSize ?? $0.fetchBatchSize
			$0.relationshipKeyPathsForPrefetching = relationshipKeyPathsForPrefetching
		}
	}

	func inContext(_ context: NSManagedObjectContext) throws -> Self {
		try context.inContext(self)
	}
}
