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

private struct Observer {
	weak var moc: NSManagedObjectContext?
	let tokens: [NSObjectProtocol]
}

public final class DB: NSObject {
	internal static let shared = DB()
	
	private var db: CoreDataDefaultStorage? = nil
	private var observers = [Observer]()
	
	private var root: NSManagedObjectContext {
		guard let main = db?.mainContext as? NSManagedObjectContext, let moc = main.parent else { fatalError("Core Data not initialized") }
		return moc
	}
	
	public static var main: NSManagedObjectContext {
		guard let moc = shared.db?.mainContext as? NSManagedObjectContext else { fatalError("Core Data not initialized") }
		return moc
	}
	
	public static var save: NSManagedObjectContext {
		let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		moc.parent = shared.root
		
		let willSave = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextWillSave, object: moc, queue: nil, using: { [weak moc] (notification) in
			guard let s = moc, s.insertedObjects.count > 0 else { return }
			_ = try? s.obtainPermanentIDs(for: Array(s.insertedObjects))
		})
		let didSave = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: moc, queue: .main, using: { (notification) -> Void in
			DB.main.mergeChanges(fromContextDidSave: notification as Notification)
		})
		
		shared.cleanupObservers()
		shared.observers += [Observer(moc: moc, tokens: [willSave, didSave])]
		
		return moc
	}
	
	public typealias SaveBlock = () -> Void
	@discardableResult public static func operation<T>(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> T) throws -> T {
		let context = save
		var _error: Error!
		var returnedObject: T!
		
		context.performAndWait {
			do {
				returnedObject = try operation(context, { () -> Void in
					do {
						try context.save()
					}
					catch {
						_error = error
					}
					shared.root.performAndWait({
						if shared.root.hasChanges {
							do {
								try shared.root.save()
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
		
		return returnedObject
	}
	
	public typealias SaveBlockWitCallback = (@escaping (Error?) -> Void) -> Void
	public static func backgroundOperation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> ()) {
		let context = save
		var _error: Error!
		
		context.perform {
			operation(context, { (callback) in
				do {
					try context.save()
				}
				catch {
					_error = error
				}
				shared.root.perform {
					if shared.root.hasChanges {
						do {
							try shared.root.save()
						}
						catch {
							_error = error
						}
					}
					callback(_error)
				}
			})
		}
	}
	
	public static func saveToPersistentStore(_ moc: NSManagedObjectContext) throws {
		guard let db = shared.db else { fatalError("Core Data not initialized") }
		
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
	
	private override init() {
		super.init()
	}
	
	@objc internal func initialize() {
		let store: CoreDataStore = .named("db")
		let model: CoreDataObjectModel = .merged([Bundle.main])
		
		do {
			db = try CoreDataDefaultStorage(store: store, model: model)
		} catch {
			try? FileManager.default.removeItem(at: store.path() as URL)
			_ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-shm")
			_ = try? FileManager.default.removeItem(atPath: "\(store.path().absoluteString)-wal")
			
			db = try? CoreDataDefaultStorage(store: store, model: model)
		}
	}
	
	@objc internal func reset() {
		do {
			try db?.removeStore()
		} catch let error {
			DDLogError("Error deleting DB store: \(error)")
		}
		db = nil
	}
	
	private func cleanupObservers() {
		var active: [Observer] = []
		
		for observer in observers {
			if observer.moc == nil {
				observer.tokens.forEach { NotificationCenter.default.removeObserver($0) }
			} else {
				active += [observer]
			}
		}
		
		observers = active
	}
}
