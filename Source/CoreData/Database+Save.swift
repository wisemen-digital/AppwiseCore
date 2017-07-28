//
//  Database+Save.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CocoaLumberjack
import CoreData
import SugarRecord

extension DB {
	public var save: NSManagedObjectContext {
		let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		
		moc.parent = root
		NotificationCenter.default.addObserver(self, selector: #selector(contextWillSave(notification:)), name: NSNotification.Name.NSManagedObjectContextWillSave, object: moc)
		NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: moc)
		
		return moc
	}
	
	public static func saveToPersistentStore(_ moc: NSManagedObjectContext) throws {
		let root = shared.root
		guard moc.parent == root else {
			throw DBError.invalidContext
		}
		
		try moc.save()
		
		guard let parent = moc.parent else { return }
		var _error: Error?
		parent.performAndWait {
			do {
				try parent.save()
			} catch {
				_error = error
			}
		}
		
		if let error = _error {
			throw error
		}
	}
	
	@objc private func contextWillSave(notification: Notification) {
		guard let moc = notification.object as? NSManagedObjectContext else { return }
		_ = try? moc.obtainPermanentIDs(for: Array(moc.insertedObjects))
	}
	
	@objc private func contextDidSave(notification: Notification) {
		guard let moc = notification.object as? NSManagedObjectContext,
			let main = db?.mainContext as? NSManagedObjectContext else { return }
		main.mergeChanges(fromContextDidSave: notification as Notification)
	}
}
