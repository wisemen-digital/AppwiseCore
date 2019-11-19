//
//  Database.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
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
	fileprivate let bundle: Bundle
	fileprivate let storeName: String
	internal var container: NSPersistentContainer

	/// The default database is a singleton (points to the main bundle).
	@objc public static let shared = DB(bundle: Bundle.main, storeName: "db")

	@available(*, renamed: "view")
	public var main: NSManagedObjectContext {
		return view
	}

	/// The main context. All UI related operations should use this context.
	public var view: NSManagedObjectContext {
		return container.viewContext
	}

	/// Creates a new DB instance with the specified bundle.
	///
	/// - parameter bundle: The bundle to work in.
	///
	/// - returns: The new DB instance.
	public required init(bundle: Bundle, storeName: String) {
		self.bundle = bundle
		self.storeName = storeName
		self.container = DB.createContainer(bundle: bundle, storeName: storeName)
		super.init()
	}

	/// The merge policy for the main (and root) contexts
	public var mergePolicy: NSMergePolicyType = .mergeByPropertyStoreTrumpMergePolicyType {
		didSet {
			main.mergePolicy = NSMergePolicy(merge: mergePolicy)
		}
	}
}

// MARK: Accessed from Config

extension DB {
	/// Initialize the data store.  It will merge all data models in the DB's bundle.
	@objc
	public func initialize() {
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
	public func reset() {
		container.viewContext.reset()
		container = DB.createContainer(bundle: bundle, storeName: storeName)

		do {
			guard let url = container.persistentStoreDescriptions.first?.url else { return }
			try container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
		} catch let error {
			DDLogError("Error deleting DB store: \(error)")
		}
	}

	private static func createContainer(bundle: Bundle, storeName: String) -> NSPersistentContainer {
		if let model = NSManagedObjectModel.mergedModel(from: [bundle]) {
			return NSPersistentContainer(name: storeName, managedObjectModel: model)
		} else {
			fatalError("Unable to load merged core data model.")
		}
	}
}
