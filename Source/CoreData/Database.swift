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

enum DBError: Error {
	case invalidContext
}

public final class DB: NSObject {
	private let bundle: Bundle
	internal var db: CoreDataDefaultStorage? = nil
	
	internal var root: NSManagedObjectContext {
		guard let moc = main.parent else { fatalError("Core Data not initialized") }
		return moc
	}
	
	public static let shared = DB(bundle: Bundle.main)
	
	public static var main: NSManagedObjectContext {
		return shared.main
	}
	
	public var main: NSManagedObjectContext {
		guard let moc = db?.mainContext as? NSManagedObjectContext else { fatalError("Core Data not initialized") }
		return moc
	}
	
	public required init(bundle: Bundle) {
		self.bundle = bundle
		super.init()
	}
}

// MARK: Accessed from Config

extension DB {
	@objc internal func initialize() {
		let store: CoreDataStore = .named("db")
		let model: CoreDataObjectModel = .merged([Bundle.main])
		
		do {
			db = try CoreDataDefaultStorage(store: store, model: model)
		} catch {
			try? FileManager.default.removeItem(at: store.path() as URL)
			_ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-shm")
			_ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-wal")
			
			db = try? CoreDataDefaultStorage(store: store, model: model)
		}
	}
	
	@objc internal func reset() {
		do {
			try db?.removeStore()
		} catch let error {
			DDLogError("Error deleting DB store: \(error)")
		}
		db = nil
	}
}
