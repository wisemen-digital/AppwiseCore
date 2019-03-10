//
//  Database.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CocoaLumberjack
import CoreData

public extension DB {
	/// A save closure with no arguments
	typealias SaveBlock = () throws -> Void
	/// A save closure with a callback argument that accepts an optional error
	typealias SaveBlockWitCallback = (@escaping (Error?) -> Void) -> Void

	/// Perform an operation asynchronously.
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	func operation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> Void) {
		container.performBackgroundTask { context in
			context.mergePolicy = NSMergePolicy(merge: self.mergePolicy)

			operation(context) { callback in
				do {
					try context.save()
					callback(nil)
				} catch {
					callback(error)
				}
			}
		}
	}
}
