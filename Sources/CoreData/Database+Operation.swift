//
//  Database.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CocoaLumberjack
import CoreData
import SugarRecord

public extension DB {
	/// A save closure with no arguments
	typealias SaveBlock = () -> Void
	/// A save closure with a callback argument that accepts an optional error
	typealias SaveBlockWitCallback = (@escaping (Error?) -> Void) -> Void

	/// Perform an operation synchronously, and return a result object
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	///
	/// - returns: The result object converted to the main context
	func operation<T: NSManagedObject>(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> T) throws -> T {
		let context = newSave()
		var resultError: Error!
		var result: T!

		context.performAndWait { [weak self] in
			do {
				result = try operation(context) { () -> Void in
					context.performAndWait {
						do {
							try context.save()
						} catch {
							resultError = error
						}
						guard let root = self?.root else { return }
						root.performAndWait {
							if root.hasChanges {
								do {
									try root.save()
								} catch {
									resultError = error
								}
							}
						}
					}
				}
			} catch {
				resultError = error
			}
		}
		if let error = resultError {
			throw error
		}

		// cast to main context
		result = try main.inContext(result)

		return result
	}

	/// Perform an operation synchronously.
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	func operation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> Void) throws {
		let context = newSave()
		var resultError: Error!

		context.performAndWait { [weak self] in
			do {
				try operation(context) { () -> Void in
					context.performAndWait {
						do {
							try context.save()
						} catch {
							resultError = error
						}
						guard let root = self?.root else { return }
						root.performAndWait {
							if root.hasChanges {
								do {
									try root.save()
								} catch {
									resultError = error
								}
							}
						}
					}
				}
			} catch {
				resultError = error
			}
		}
		if let error = resultError {
			throw error
		}
	}

	/// Perform an operation asynchronously.
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	func backgroundOperation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> Void) {
		let context = newSave()
		var resultError: Error!

		context.perform { [weak self] in
			operation(context) { callback in
				context.perform {
					do {
						try context.save()
					} catch {
						resultError = error
					}
					guard let root = self?.root else {
						return DispatchQueue.main.async {
							callback(resultError)
						}
					}

					root.perform {
						if root.hasChanges {
							do {
								try root.save()
							} catch {
								resultError = error
							}
						}
						DispatchQueue.main.async {
							callback(resultError)
						}
					}
				}
			}
		}
	}
}
