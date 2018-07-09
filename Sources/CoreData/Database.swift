//
//  Database.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CocoaLumberjack
import CoreData
import SugarRecord

public enum DBError: Error {
	/// The provided context is not available for the requested operation.
	case invalidContext
}

/// Container for all core data related operations.
// swiftlint:disable:next type_name
public final class DB: NSObject {
	fileprivate let bundle: Bundle
	internal var db: CoreDataDefaultStorage?

	internal var root: NSManagedObjectContext {
		guard let moc = main.parent else { fatalError("Core Data not initialized") }
		return moc
	}

	/// The default database is a singleton (points to the main bundle).
	@objc public static let shared = DB(bundle: Bundle.main)

	/// The main context, equivalent of `DB.shared.main`
	@available(*, renamed: "shared.main", message: "You should use the `main` variable on `DB.shared` instead.")
	public static var main: NSManagedObjectContext {
		return shared.main
	}

	/// The main context. All UI related operations should use this context.
	public var main: NSManagedObjectContext {
		guard let moc = db?.mainContext as? NSManagedObjectContext else { fatalError("Core Data not initialized") }
		return moc
	}

	/// Creates a new DB instance with the specified bundle.
	///
	/// - parameter bundle: The bundle to work in.
	///
	/// - returns: The new DB instance.
	public required init(bundle: Bundle) {
		self.bundle = bundle
		super.init()
	}
}

// MARK: Accessed from Config

extension DB {
	@objc
	internal func initialize() {
		initialize(storeName: "db")
	}

	/// Initialize the data store with a specific name. Necessary if you have multiple data stores.
	/// It will merge all data models in the DB's bundle.
	///
	/// - parameter storeName: The name of the data store.
	public func initialize(storeName: String) {
		let store: CoreDataStore = .named(storeName)
		let model: CoreDataObjectModel = .merged([bundle])

		do {
			db = try CoreDataDefaultStorage(store: store, model: model)
		} catch {
			try? FileManager.default.removeItem(at: store.path() as URL)
			_ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-shm")
			_ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-wal")

			db = try? CoreDataDefaultStorage(store: store, model: model)
		}
	}

	/// Reset the data store (effectively deletes it).
	@objc
	public func reset() {
		do {
			try db?.removeStore()
		} catch let error {
			DDLogError("Error deleting DB store: \(error)")
		}
		db = nil
	}
}
