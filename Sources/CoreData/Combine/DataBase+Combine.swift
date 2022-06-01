//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Combine
import CoreData

@available(iOS 13.0, *)
public extension DB {
	/// Perform an operation asynchronously.
	///
	/// - parameter queue: The queue on which your completion handler is dispatched.
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	func operation(queue: DispatchQueue = .main, operation: @escaping (_ context: NSManagedObjectContext) throws -> Void) -> AnyPublisher<Void, Error> {
		Future { promise in
			self.operation(queue: queue) { context, save in
				do {
					try operation(context)
					save {
						if let error = $0 {
							promise(.failure(error))
						} else {
							promise(.success(()))
						}
					}
				} catch {
					promise(.failure(error))
				}
			}
		}
		.eraseToAnyPublisher()
	}

	/// Save the changes in the given context to the persistent store.
	///
	/// - parameter moc: The managed object context.
	/// - parameter queue: The queue on which your completion handler is dispatched.
	func saveToPersistentStore(_ moc: NSManagedObjectContext, queue: DispatchQueue = .main) -> AnyPublisher<Void, Error> {
		Future { promise in
			self.saveToPersistentStore(moc, queue: queue) { error in
				if let error = error {
					promise(.failure(error))
				} else {
					promise(.success(()))
				}
			}
		}
		.eraseToAnyPublisher()
	}
}
