//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CocoaLumberjack
import CoreData

internal extension DB {
	/// Try to execute all migrations defined for the given storage. Will skip if there are no defined migrations.
	///
	/// - parameter storage: The storage to migrate
	/// - parameter handler: Callback when done, errors are logged to console.
	func migrate(storage: Storage, handler: @escaping () -> Void) {
		// collect stores with migrations
		let items = storage.storeConfigurations.compactMap { config in
			config.migration.map { (migration: $0, newStore: config.description) }
		}

		// execute them in parallel (early exit if possible)
		guard !items.isEmpty else { handler(); return }
		let group = DispatchGroup()

		for item in items {
			group.enter()
			execute(migration: item.migration, newStore: item.newStore) { _ in
				group.leave()
			}
		}

		group.notify(queue: .main) {
			handler()
		}
	}
}

private extension DB {
	func execute(migration: StoreConfiguration.Migration, newStore: NSPersistentStoreDescription, handler: @escaping (Error?) -> Void) {
		load(storeDescription: migration.oldStore) { [weak self] result in
			switch result {
			case .success(let store):
				self?.migrate(store: store, newStore: newStore) { error in
					if error == nil {
						self?.delete(store: migration.oldStore)
					}
					handler(error)
				}
			case .failure(let error):
				handler(error)
			}
		}
	}

	func load(storeDescription: NSPersistentStoreDescription, handler: @escaping (Result<NSPersistentStore, Error>) -> Void) {
		let coordinator = container.persistentStoreCoordinator
		coordinator.addPersistentStore(with: storeDescription) { [weak self] storeDescription, error in
			if let error = error {
				handler(.failure(error))
			} else if let store = coordinator.persistentStores.first(where: { $0.url == storeDescription.url }) {
				self?.didLoad(store: storeDescription)
				handler(.success(store))
			} else {
				handler(.failure(StoreNotFoundError()))
			}
		}
	}

	func migrate(store: NSPersistentStore, newStore: NSPersistentStoreDescription, handler: @escaping (Error?) -> Void) {
		guard let url = newStore.url else { handler(nil); return }

		do {
			let newStore = try container.persistentStoreCoordinator.migratePersistentStore(store, to: url, options: newStore.options, withType: newStore.type)
			handler(nil)
		} catch {
			DDLogError("Error migrating store: \(error)")
			handler(error)
		}
	}
}
