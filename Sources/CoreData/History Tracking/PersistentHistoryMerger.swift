//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CocoaLumberjack
import CoreData

@available(iOS 13, *)
struct PersistentHistoryMerger {
	let store: NSPersistentStore
	let author: Author
	let backgroundContext: NSManagedObjectContext
	let viewContext: NSManagedObjectContext
	let settings: PersistentHistorySettings

	func merge() throws {
		let key = PersistentHistorySettings.Key(storeID: store.identifier, author: author)
		let date = settings.lastHistory(key: key) ?? .distantPast
		let fetcher = PersistentHistoryFetcher(store: store, context: backgroundContext, from: date)
		let transactions = try fetcher.fetch()

		if !transactions.isEmpty {
			merge(transactions: transactions)
		}
	}
}

// MARK: - Helpers

@available(iOS 13, *)
private extension PersistentHistoryMerger {
	func merge(transactions: [NSPersistentHistoryTransaction]) {
		DDLogInfo("Merging \(transactions.count) transactions")

		for transaction in transactions {
			guard let info = transaction.objectIDNotification().userInfo else { continue }
			NSManagedObjectContext.mergeChanges(fromRemoteContextSave: info, into: [viewContext])
		}

		if let date = transactions.last?.timestamp {
			let key = PersistentHistorySettings.Key(storeID: store.identifier, author: author)
			settings.updateLastHistory(key: key, date: date)
		}
	}
}
