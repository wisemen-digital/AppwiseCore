//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CocoaLumberjack
import CoreData

internal extension DB {
	/// Configures some general properties on the container, such as merge policies.
	func preInitialize() {
		container.viewContext.do {
			$0.automaticallyMergesChangesFromParent = true
			$0.mergePolicy = NSMergePolicy(merge: mergePolicy)
		}
	}

	/// Starts the initialization of all of the container's  persistent stores. Once finished, it'll update the state to either `initialized` or `failed`.
	///
	/// - parameter attemptRecovery: Wether to attempt a recovery on failing to init a store. If true, this will only happen once (no endless recovery loop)
	func loadStores(attemptRecovery: Bool) {
		let total = container.persistentStoreDescriptions.count

		var loaded = 0
		var failedStores: [NSPersistentStoreDescription] = []

		container.loadPersistentStores { [weak self] store, error in
			guard let self = self else { return }

			loaded += 1

			if let error = error {
				DDLogError("Error loading DB store: \(error)")
				failedStores.append(store)
			} else {
				store.url.map { DDLogInfo("Store URL: \($0)") }
				self.didLoad(store: store)
			}

			if loaded == total && !failedStores.isEmpty {
				failedStores.forEach { self.delete(store: $0) }
				self.loadStores(attemptRecovery: false)
			}
		}
	}
}
