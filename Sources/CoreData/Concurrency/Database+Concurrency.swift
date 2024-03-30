//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import CoreData

@available(iOS 13.0, *)
public extension DB {
	// Perform an operation asynchronously.
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	func operation(operation: @escaping (_ context: NSManagedObjectContext) throws -> Void) async throws {
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
			self.operation { context, save in
				do {
					try operation(context)

					save { error in
						if let error = error {
							continuation.resume(throwing: error)
						} else {
							continuation.resume(returning: ())
						}
					}
				} catch {
					continuation.resume(throwing: error)
				}
			}
		}
	}

	/// Save the changes in the given context to the persistent store.
	///
	/// - parameter moc: The managed object context.
	func saveToPersistentStore(_ moc: NSManagedObjectContext) async throws {
		try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
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
