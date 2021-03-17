//
//  Database+Save.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CocoaLumberjack
import CoreData

public extension DB {
	/// Create a new temporary save context. Call `saveToPersistentStore(_:)` with it
	/// when done.
	///
	/// - returns: The new context.
	func newBackgroundContext() -> NSManagedObjectContext {
		return container.newBackgroundContext().then {
			$0.mergePolicy = NSMergePolicy(merge: self.mergePolicy)
		}
	}

	/// Save the changes in the given context to the persistent store.
	///
	/// - parameter moc: The managed object context.
	/// - parameter queue: The queue on which your completion handler is dispatched.
	/// - parameter handler: The callback after saving.
	func saveToPersistentStore(_ moc: NSManagedObjectContext, queue: DispatchQueue = .main, then handler: @escaping (Error?) -> Void) {
		moc.perform {
			do {
				try moc.save()
				queue.async { handler(nil) }
			} catch {
				queue.async { handler(error) }
			}
		}
	}
}
