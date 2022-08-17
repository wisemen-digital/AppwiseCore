//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

@available(iOS 13, *)
struct PersistentHistoryFetcher {
	let store: NSPersistentStore
	let context: NSManagedObjectContext
	let from: Date

	func fetch() throws -> [NSPersistentHistoryTransaction] {
		let fetchRequest = try NSPersistentHistoryChangeRequest.fetchHistory(after: from).then {
			$0.fetchRequest = try buildFetchRequest()
			$0.affectedStores = [store]
		}

		if let result = try context.execute(fetchRequest) as? NSPersistentHistoryResult,
		   let transactions = result.result as? [NSPersistentHistoryTransaction] {
			return transactions
		} else {
			throw PersistentHistoryError.transactionConvertionFailed
		}
	}
}

// MARK: - Helpers

@available(iOS 13, *)
private extension PersistentHistoryFetcher {
	func buildPredicate() -> NSPredicate {
		var predicates: [NSPredicate] = []

		if let transactionAuthor = context.transactionAuthor {
			predicates.append(NSPredicate(format: "%K != %@", #keyPath(NSPersistentHistoryTransaction.author), transactionAuthor))
		}

		return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
	}

	func buildFetchRequest() throws -> NSFetchRequest<NSFetchRequestResult> {
		if let fetchRequest = NSPersistentHistoryTransaction.fetchRequest {
			return fetchRequest.then {
				$0.predicate = buildPredicate()
			}
		} else {
			throw PersistentHistoryError.fetchRequestFailed
		}
	}
}
