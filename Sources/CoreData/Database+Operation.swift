//
// AppwiseCore
// Copyright © 2024 Wisemen
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
	/// - parameter queue: The queue on which your completion handler is dispatched.
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	func operation(queue: DispatchQueue = .main, operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> Void) {
		container.performBackgroundTask { context in
			context.mergePolicy = NSMergePolicy(merge: self.mergePolicy)

			operation(context) { callback in
				do {
					try context.save()
					queue.async { callback(nil) }
				} catch {
					queue.async { callback(error) }
				}
			}
		}
	}
}
