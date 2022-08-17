//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CocoaLumberjack
import CoreData

// MARK: - Initialization

internal extension DB {
	/// Configures some general properties on the container, such as merge policies.
	func preInitialize() {
		container.viewContext.do {
			$0.automaticallyMergesChangesFromParent = true
			$0.mergePolicy = NSMergePolicy(merge: mergePolicy)

			if #available(iOS 11.0, *) {
				$0.name = ContextAuthor.view.name
				$0.transactionAuthor = storage.author?.name
			}
		}
	}

	/// Configures history tracking after initialization
	func postInitialize() {
		trackers = container.persistentStoreCoordinator.persistentStores.filter(\.canTrackPersistentHistory).flatMap {
			if let author = storage.author, let settings = storage.historySettings(for: $0) {
				return PersistentHistoryTracker(author: author, settings: settings, store: $0, persistentContainer: container)
			} else {
				return nil
			}
		}

		trackers.forEach { $0.start() }
	}
}

// MARK: - Loading

internal extension DB {
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

			if loaded == total {
				if failedStores.isEmpty {
					self.postInitialize()
					self.state = .initialized
				} else if attemptRecovery {
					failedStores.forEach { self.delete(store: $0) }
					self.loadStores(attemptRecovery: false)
				} else {
					self.state = .failed
				}
			}
		}
	}
}
