//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CocoaLumberjack
import CoreData

public enum DBError: Error {
	/// The provided context is not available for the requested operation.
	case invalidContext
}

/// Container for all core data related operations.
// swiftlint:disable:next type_name
public final class DB: NSObject {
	/// The default database is a singleton (points to the main bundle).
	@objc public static let shared = DB(storage: defaultStorage)

	/// The default storage for the singleton, `SQLiteStoragelegacy` unless overridden.
	public static var defaultStorage: Storage = SQLiteStorage.legacy

	/// Reference to storage definition
	internal let storage: Storage

	/// The persistent container (based on storage definition)
	internal lazy var container: NSPersistentContainer = storage.createContainer()

	@available(*, renamed: "view")
	public var main: NSManagedObjectContext {
		view
	}

	/// The main context. All UI related operations should use this context.
	public var view: NSManagedObjectContext {
		container.viewContext
	}

	/// Creates a new DB instance with the specified storage
	///
	/// - parameter storage: The configuration of the databases
	///
	/// - returns: The new DB instance.
	public required init(storage: Storage) {
		self.storage = storage
		super.init()
	}

	/// Creates a new DB instance with the specified bundle.
	///
	/// - parameter bundle: The bundle to work in.
	///
	/// - returns: The new DB instance.
	@available(*, deprecated, message: "use init(storage:) instead")
	public required init(bundle: Bundle, storeName: String) {
		let url = SQLiteStorage.defaultFileURL(name: storeName).require()
		let configuration = ModelConfiguration(name: storeName, bundle: bundle).require()

		storage = SQLiteStorage(fileURL: url, configuration: configuration).with {
			$0.addStoreAsynchronously = false
		}
	}

	/// The merge policy for the main (and root) contexts
	public var mergePolicy: NSMergePolicyType = .mergeByPropertyStoreTrumpMergePolicyType {
		didSet {
			main.mergePolicy = NSMergePolicy(merge: mergePolicy)
		}
	}
}

// MARK: Accessed from Config

public extension DB {
	/// Initialize the data store.
	@objc
	func initialize() {
		container.loadPersistentStores { [weak self] storeDescription, error in
			DDLogInfo("Store URL: \(String(describing: storeDescription.url ?? URL(string: "")))")

			if error != nil, let url = storeDescription.url {
				try? self?.container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
				self?.container.loadPersistentStores { _, _ in
				}
			}
		}

		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergePolicy(merge: mergePolicy)
	}

	/// Reset the data store (effectively deletes it).
	@objc
	func reset() {
		container.viewContext.reset()
		container = storage.createContainer()

		do {
			guard let url = container.persistentStoreDescriptions.first?.url else { return }
			try container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
		} catch {
			DDLogError("Error deleting DB store: \(error)")
		}
	}
}
