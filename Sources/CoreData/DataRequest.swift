//
//  DataRequest.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Alamofire
import AlamofireCoreData
import CoreData

public extension DataRequest {
	/// Adds a handler to be called once the request has finished.
	///
	/// - parameter queue:             The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonSerializer:    The response JSON serializer
	/// - parameter type:              The `Insertable` type that will be used in the serialization
	/// - parameter contextObject:     The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter completionHandler: The code to be executed once the request has finished.
	///
	/// - returns: the request
	@available(*, deprecated, message: "Use `responseInsert` without a `NSManagedObjectContext` in the callback, and use the `Importable` protocol")
	@discardableResult
	func responseInsert<T: Insertable>(
		db: DB = DB.shared,
		queue: DispatchQueue? = nil,
		jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
		type: T.Type,
		contextObject: Any? = nil,
		completionHandler: @escaping (DataResponse<T>, NSManagedObjectContext, @escaping DB.SaveBlockWitCallback) -> Void)
		-> Self {
		db.backgroundOperation { moc, save in
			self.responseInsert(queue: queue, jsonSerializer: jsonSerializer, context: moc, type: T.self) { response in
				response.handleImport(moc: moc, queue: queue, serializer: jsonSerializer, contextObject: contextObject) { response in
					completionHandler(response, moc, save)
				}
			}
		}

		return self
	}

	/// Adds a handler to be called once the request has finished.
	///
	/// - parameter queue:             The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonSerializer:    The response JSON serializer
	/// - parameter type:              The `Insertable` type that will be used in the serialization
	/// - parameter contextObject:     The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter completionHandler: The code to be executed once the request has finished.
	///
	/// - returns: the request
	@discardableResult
	func responseInsert<T: Insertable>(
		db: DB = DB.shared,
		queue: DispatchQueue? = nil,
		jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
		type: T.Type,
		contextObject: Any? = nil,
		completionHandler: @escaping (DataResponse<T>, @escaping DB.SaveBlockWitCallback) -> Void)
		-> Self {
		db.backgroundOperation { moc, save in
			self.responseInsert(queue: queue, jsonSerializer: jsonSerializer, context: moc, type: T.self) { response in
				response.handleImport(moc: moc, queue: queue, serializer: jsonSerializer, contextObject: contextObject) { response in
					completionHandler(response, save)
				}
			}
		}

		return self
	}
}

extension DataResponse {
	/// Convert a response's result to a failure
	func with(error: Error) -> DataResponse<Value> {
		return DataResponse(
			request: request,
			response: response,
			data: data,
			result: .failure(error),
			timeline: timeline
		)
	}

	/// If needed, call the `Importable` (and related) methods on the moc's thread, with
	/// the json used by the importer
	func handleImport(
		moc: NSManagedObjectContext,
		queue: DispatchQueue?,
		serializer: DataResponseSerializer<Any>,
		contextObject: Any?,
		completionHandler: @escaping (DataResponse<Value>) -> Void) {
		switch result {
		case let .success(value as Importable):
			moc.perform {
				let callbackQueue = queue ?? DispatchQueue.main
				do {
					if let data = serializer.serialize(response: self).value {
						let context = ImportContext(moc: moc, object: contextObject)
						try value.didImport(data: data, context: context)
					}

					callbackQueue.async {
						completionHandler(self)
					}
				} catch {
					callbackQueue.async {
						completionHandler(self.with(error: error))
					}
				}
			}
		default:
			completionHandler(self)
		}
	}
}

extension DataResponseSerializer {
	func serialize<T>(response: DataResponse<T>) -> Result<Value> {
		return serializeResponse(response.request, response.response, response.data, response.error)
	}
}
