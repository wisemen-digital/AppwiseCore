//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import CocoaLumberjack
import CoreData

extension DB {
	func didLoad(store: NSPersistentStoreDescription) {
		if let index = container.persistentStoreDescriptions.firstIndex(of: store) {
			container.persistentStoreDescriptions.remove(at: index)
		}
	}

	/// Try to delete the data of the given persistent store. Will log an error on failure.
	///
	/// - parameter store: The store's description
	func delete(store: NSPersistentStoreDescription) {
		guard let url = store.url else { return }

		do {
			try container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: store.type)
		} catch {
			DDLogError("Error deleting DB store: \(error)")
		}
	}

	public struct StoreNotFoundError: Error { }
}
