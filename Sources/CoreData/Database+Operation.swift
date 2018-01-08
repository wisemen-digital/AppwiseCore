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

extension DB {
	/// A save closure with no arguments
	public typealias SaveBlock = () -> Void
	/// A save closure with a callback argument that accepts an optional error
	public typealias SaveBlockWitCallback = (@escaping (Error?) -> Void) -> Void

	/// Perform an operation synchronously, and return a result object
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	///
	/// - returns: The result object converted to the main context
	@available(*, renamed: "shared.operation", message: "You should invoke this on `DB.shared` instead.")
	public static func operation<T: NSManagedObject>(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> T) throws -> T {
		return try shared.operation(operation)
	}

	/// Perform an operation synchronously, and return a result object
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	///
	/// - returns: The result object converted to the main context
	public func operation<T: NSManagedObject>(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> T) throws -> T {
		let context = newSave()
		var _error: Error!
		var result: T!
		
		context.performAndWait { [weak self] in
			do {
				result = try operation(context, { () -> Void in
					do {
						try context.save()
					} catch {
						_error = error
					}
					guard let root = self?.root else { return }
					root.performAndWait({
						if root.hasChanges {
							do {
								try root.save()
							} catch {
								_error = error
							}
						}
					})
				})
			} catch {
				_error = error
			}
		}
		if let error = _error {
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
	@available(*, renamed: "shared.operation", message: "You should invoke this on `DB.shared` instead.")
	public static func operation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> Void) throws {
		try shared.operation(operation)
	}

	/// Perform an operation synchronously.
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	public func operation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> Void) throws {
		let context = newSave()
		var _error: Error!

		context.performAndWait { [weak self] in
			do {
				try operation(context, { () -> Void in
					do {
						try context.save()
					} catch {
						_error = error
					}
					guard let root = self?.root else { return }
					root.performAndWait({
						if root.hasChanges {
							do {
								try root.save()
							} catch {
								_error = error
							}
						}
					})
				})
			} catch {
				_error = error
			}
		}
		if let error = _error {
			throw error
		}
	}

	/// Perform an operation asynchronously.
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	@available(*, renamed: "shared.backgroundOperation", message: "You should invoke this on `DB.shared` instead.")
	public static func backgroundOperation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> ()) {
		shared.backgroundOperation(operation)
	}

	/// Perform an operation asynchronously.
	///
	/// - parameter operation: The closure to perform within a new context.
	/// - parameter context: The temporary save context.
	/// - parameter save: The save closure, you should call this when you're ready to save.
	public func backgroundOperation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> ()) {
		let context = newSave()
		var _error: Error!
		
		context.perform { [weak self] in
			operation(context, { (callback) in
				do {
					try context.save()
				} catch {
					_error = error
				}
				guard let root = self?.root else {
					return DispatchQueue.main.async {
						callback(_error)
					}
				}
				
				root.perform {
					if root.hasChanges {
						do {
							try root.save()
						} catch {
							_error = error
						}
					}
					DispatchQueue.main.async {
						callback(_error)
					}
				}
			})
		}
	}
}
