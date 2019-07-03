//
//  DataRequest.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Alamofire
import CoreData

/// A wrapper which encapsulate all the info of the response of a Request 
public struct ResponseInfo {
    public let request: URLRequest?
    public let response: HTTPURLResponse?
    public let data: Data?
    public let error: Error?
}

public extension DataResponseSerializer {
    /// Create a new `DataResponseSerializer` which serialize the response in two steps:
    /// - first, it serialize the response using the serializer sent in the parent parameter
    /// - second, take the `Result` returned by the parent and process it using the given transformer
    /// - parameter parent:             The serializer used in the first serialization
    /// - parameter transformer:        The block used for the second serialization
    ///
    /// - returns: a new instance of the serializer
    init<ParentValue>(
        parent: DataResponseSerializer<ParentValue>,
        transformer: @escaping (ResponseInfo, Result<ParentValue>) -> Result<Value>
    ) {
        self.init { request, response, data, error -> Result<Value> in
            let initialResponse = parent.serializeResponse(request, response, data, error)
            return transformer(
                ResponseInfo(request: request, response: response, data: data, error: error),
                initialResponse)
        }
    }
}

public extension DataRequest {
    /// Initialize a serializer built in two steps:
    /// - The first step serializes the response to get a `JSON`.
    /// - The second step transform the previous `JSON` using the given transformer
    ///
    /// - parameter options:     The JSON serialization reading options. Default is `.allowFragments`
    /// - parameter transformer: The transformer used to proccess the default `JSON`
    ///
    /// - returns: the new serializer
    static func jsonTransformerSerializer(
        options: JSONSerialization.ReadingOptions = .allowFragments,
        transformer: @escaping ((ResponseInfo, Result<Any>) -> Result<Any>)
        ) -> DataResponseSerializer<Any> {
        let parentSerializer = DataRequest.jsonResponseSerializer(options: options)
        return DataResponseSerializer(parent: parentSerializer, transformer: transformer)
    }

    /// Creates a response serializer that returns a `Insertable` object result type constructed from the response data using. 
    /// The `Insertable` will be inserted in the given context before being returned.
    ///
    /// - parameter context:        The `NSManagedObjectContext` where the `Insertable` will be inserted
    /// - parameter type:           The `Insertable` type that will be used in the serialization
    /// - parameter jsonSerializer: A `DataResultSerializer` which must return the JSON which will be used to perform the insert. Default is a `DataRequest.jsonResponseSerializer()`
    /// - parameter contextObject:  The object to pass along to an import operation (see `ImportContext.object`)
    ///
    /// - returns: An `Insertable` object response serializer.
    class func responseInsertSerializer<T: Insertable>(
        context moc: NSManagedObjectContext,
        type: T.Type,
        jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
        contextObject: Any? = nil
    ) -> DataResponseSerializer<T> {
        return DataResponseSerializer(parent: jsonSerializer) { _, result -> Result<T> in
            guard result.isSuccess else {
				return .failure(result.error.require(hint: "Result is failure, but has no error"))
            }

            do {
				let data = result.value ?? [:]
                let value: T = try T.insert(from: data, in: moc)

				if let value = value as? Importable {
					let importContext = ImportContext(moc: moc, object: contextObject)
					try handleImport(value: value, data: data, context: importContext)
				}
                return .success(value)
            } catch let error {
                return .failure(error)
            }
        }
    }

	/// Helper method to perform handleImport on context queue, and catch any resulting error.
	fileprivate static func handleImport(value: Importable, data: Any, context: ImportContext) throws {
		var importError: Error?

		context.moc.performAndWait {
			do {
				try value.didImport(from: data, in: context)
			} catch {
				importError = error
			}
		}

		if let error = importError {
			throw error
		}
	}

	// swiftlint:disable function_default_parameter_at_end
	/// Adds a handler to be called once the request has finished.
	///
	/// - parameter db:                The database to work in
	/// - parameter queue:             The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonSerializer:    The response JSON serializer
	/// - parameter type:              The `Insertable` type that will be used in the serialization
	/// - parameter contextObject:     The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter handler: The code to be executed once the request has finished.
	///
	/// - returns: the request
	@discardableResult
	func responseInsert<T: Insertable>(
		db: DB = DB.shared,
		queue: DispatchQueue? = nil,
		jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
		type: T.Type,
		contextObject: Any? = nil,
		then handler: @escaping (DataResponse<T>, @escaping DB.SaveBlockWitCallback) -> Void
	) -> Self {
		let context = db.newBackgroundContext()
		let save: DB.SaveBlockWitCallback = { completion in
			context.perform {
				do {
					try context.save()
					(queue ?? DispatchQueue.main).async {
						completion(nil)
					}
				} catch {
					(queue ?? DispatchQueue.main).async {
						completion(error)
					}
				}
			}
		}

		let serializer = DataRequest.responseInsertSerializer(
			context: context,
			type: T.self,
			jsonSerializer: jsonSerializer,
			contextObject: contextObject
		)

		return response(queue: queue, responseSerializer: serializer) { response in
			handler(response, save)
		}
	}
}
