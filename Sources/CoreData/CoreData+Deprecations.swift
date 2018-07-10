//
//  Deprecations.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2018 Appwise. All rights reserved.
//

import Alamofire
import CoreData

@available(*, unavailable, renamed: "Insertable")
public protocol Importable {
	@available(*, deprecated, message: "didImport(from:in:)")
	func didImport(data: Any, context: ImportContext) throws
}

@available(*, unavailable, renamed: "ManyInsertable")
public protocol ManyImportable {
	@available(*, deprecated, renamed: "didImport(item:from:in:)")
	static func didImport(item: Any, data: Any, context: ImportContext) throws

	@available(*, deprecated, renamed: "didImport(items:from:in:)")
	static func didImport(items: [Any], data: [Any], context: ImportContext) throws
}

public extension DataRequest {
	@available(*, unavailable, message: "Use `responseInsert` without a `NSManagedObjectContext` in the callback, and use the `Insertable` protocol")
	@discardableResult
	func responseInsert<T: Insertable>(db: DB = DB.shared, queue: DispatchQueue? = nil, jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(), type: T.Type, contextObject: Any? = nil, completionHandler: @escaping (DataResponse<T>, NSManagedObjectContext, @escaping DB.SaveBlockWitCallback) -> Void) -> Self {
		fatalError("Unavailable")
	}
}

public extension DB {
	@available(*, unavailable, renamed: "shared.operation", message: "You should invoke this on `DB.shared` instead.")
	static func operation<T: NSManagedObject>(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> T) throws -> T {
		fatalError("Unavailable")
	}

	@available(*, unavailable, renamed: "shared.operation", message: "You should invoke this on `DB.shared` instead.")
	static func operation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlock) throws -> Void) throws {
	}

	@available(*, unavailable, renamed: "shared.backgroundOperation", message: "You should invoke this on `DB.shared` instead.")
	static func backgroundOperation(_ operation: @escaping (_ context: NSManagedObjectContext, _ save: @escaping SaveBlockWitCallback) -> Void) {
	}
}

#if !(swift(>=4.2))
public func <- <T: Insertable>( left: inout T!, right: MapValue?) {
    if let mapValue = right {
        let value: T? = mapValue.serialize()
        left = value
    }
}
#endif
