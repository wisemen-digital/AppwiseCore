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
	public typealias SaveBlock = () -> Void
	public typealias SaveBlockWitCallback = (@escaping (Error?) -> Void) -> Void
	
	public static func operation<T: NSManagedObject>(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> T) throws -> T {
		return try shared.operation(operation)
	}
	
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

	public static func operation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> Void) throws {
		try shared.operation(operation)
	}

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
	
	public static func backgroundOperation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> ()) {
		shared.backgroundOperation(operation)
	}
	
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