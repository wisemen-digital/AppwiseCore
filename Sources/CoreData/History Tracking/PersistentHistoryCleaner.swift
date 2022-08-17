//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

@available(iOS 13, *)
struct PersistentHistoryCleaner {
	let store: NSPersistentStore
	let context: NSManagedObjectContext
	let settings: PersistentHistorySettings

	/// Cleans up the persistent history by deleting the transactions that have been merged into each target.
	func clean() throws {
		let date: Date
		let expiry = settings.expiryDate

		if let lastCommon = settings.oldestHistory(storeID: store.identifier), lastCommon > expiry {
			date = lastCommon
		} else {
			date = expiry
		}

		let deleteHistoryRequest = NSPersistentHistoryChangeRequest.deleteHistory(before: date)
		deleteHistoryRequest.affectedStores = [store]
		try context.execute(deleteHistoryRequest)

		settings.reset(storeID: store.identifier)
	}
}
