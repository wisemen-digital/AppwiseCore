//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CocoaLumberjack
import CoreData

public extension DB {
	/// Create a new temporary save context. Call `saveToPersistentStore(_:)` with it
	/// when done.
	///
	/// - returns: The new context.
	func newBackgroundContext() -> NSManagedObjectContext {
		container.newBackgroundContext().then {
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

@available(iOS 13, *)
public extension DB {
	/// Save the changes in the given context to the persistent store.
	///
	/// - parameter moc: The managed object context.
	func saveToPersistentStore(_ moc: NSManagedObjectContext) async throws {
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			self.saveToPersistentStore(moc) { error in
				if let error = error {
					continuation.resume(throwing: error)
				} else {
					continuation.resume(returning: ())
				}
			}
		}
	}
}
