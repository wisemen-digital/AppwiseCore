//
//  Database.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CoreData
import SugarRecord

public final class DB: NSObject {
	internal static let shared = DB()
	
	private var db: CoreDataDefaultStorage? = nil
	
	public static var main: NSManagedObjectContext {
		guard let moc = shared.db?.mainContext as? NSManagedObjectContext else { fatalError("Core Data not initialized") }
		return moc
	}
	
	public static var save: NSManagedObjectContext {
		guard let moc = shared.db?.saveContext as? NSManagedObjectContext else { fatalError("Core Data not initialized") }
		return moc
	}
	
	public typealias SaveBlock = () -> Void
	@discardableResult public static func operation<T>(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> T) throws -> T {
		guard let db = shared.db else { fatalError("Core Data not initialized") }
		return try db.operation() { (context, save) throws in
			try operation(context as! NSManagedObjectContext, save)
		}
	}
	
	private override init() {
		super.init()
	}
	
	@objc internal func initialize() {
		let store: CoreDataStore = .named("db")
		let model: CoreDataObjectModel = .merged([Bundle.main])
		
		db = try? CoreDataDefaultStorage(store: store, model: model)
	}
	
	@objc internal func reset() {
		try? db?.removeStore()
		db = nil
	}
}
