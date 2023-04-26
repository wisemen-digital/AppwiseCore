//
// AppwiseCore
// Copyright © 2023 Wisemen
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

/// A `ResponseSerializer` that decodes the response data using `JSONSerialization` and then imports
/// it into Core Data using `Groot`. By default, a request returning `nil` or no data is considered an error.
/// However, if the request has an `HTTPMethod` or the response has an HTTP status code valid for empty
/// responses, then an `NSNull` value is returned.
public final class InsertResponseSerializer<T: Insertable>: ResponseSerializer {
	public let dataPreprocessor: DataPreprocessor
	public let emptyResponseCodes: Set<Int>
	public let emptyRequestMethods: Set<HTTPMethod>
	/// `JSONSerialization.ReadingOptions` used when serializing a response.
	public let jsonOptions: JSONSerialization.ReadingOptions
	/// Closure to modify the decoded JSON object
	public let jsonTransformer: (Any) throws -> Any
	/// The Core Data context to work with
	public let context: NSManagedObjectContext
	/// The context object to pass along during import
	public let contextObject: Any?

	// swiftlint:disable function_default_parameter_at_end
	/// Creates an instance with the provided values.
	///
	/// - Parameters:
	///   - dataPreprocessor:    `DataPreprocessor` used to prepare the received `Data` for serialization.
	///   - emptyResponseCodes:  The HTTP response codes for which empty responses are allowed. `[204, 205]` by default.
	///   - emptyRequestMethods: The HTTP request methods for which empty responses are allowed. `[.head]` by default.
	///   - jsonOptions:         The options to use. `.allowFragments` by default.
	public init(
		dataPreprocessor: DataPreprocessor = InsertResponseSerializer.defaultDataPreprocessor,
		emptyResponseCodes: Set<Int> = InsertResponseSerializer.defaultEmptyResponseCodes,
		emptyRequestMethods: Set<HTTPMethod> = InsertResponseSerializer.defaultEmptyRequestMethods,
		jsonOptions: JSONSerialization.ReadingOptions = .allowFragments,
		jsonTransformer: @escaping (Any) throws -> Any = { $0 },
		context: NSManagedObjectContext,
		type: T.Type = T.self,
		contextObject: Any? = nil
	) {
		self.dataPreprocessor = dataPreprocessor
		self.emptyResponseCodes = emptyResponseCodes
		self.emptyRequestMethods = emptyRequestMethods
		self.jsonOptions = jsonOptions
		self.jsonTransformer = jsonTransformer
		self.context = context
		self.contextObject = contextObject
	}

	public func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws -> T {
		guard error == nil else { throw error! }

		// process data
		guard var data = data, !data.isEmpty || emptyResponseAllowed(forRequest: request, response: response) else {
			throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
		}
		data = try dataPreprocessor.preprocess(data)

		// decode into JSON
		var jsonData: Any
		do {
			jsonData = try JSONSerialization.jsonObject(with: data, options: jsonOptions)
			jsonData = try jsonTransformer(jsonData)
		} catch {
			throw AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error))
		}

		// import into core data
		do {
			let value: T = try T.insert(from: jsonData, in: context)

			if let value = value as? Importable {
				let importContext = ImportContext(moc: context, object: contextObject)
				try handleImport(value: value, data: jsonData, context: importContext)
			}

			return value
		} catch {
			throw AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error))
		}
	}

	/// Helper method to perform handleImport on context queue, and catch any resulting error.
	private func handleImport(value: Importable, data: Any, context: ImportContext) throws {
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
}

public extension DataRequest {
	/// Adds a handler to be called once the request has finished.
	///
	/// - parameter type:              The `Insertable` type that will be used in the serialization
	/// - parameter db:                The database to work in
	/// - parameter queue:             The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonOptions:       JSON decoder options
	/// - parameter jsonTransformer:   The response JSON transformer
	/// - parameter contextObject:     The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter handler:           The code to be executed once the request has finished.
	///
	/// - returns: the request
	@discardableResult
	func responseInsert<T: Insertable>(
		of type: T.Type = T.self,
		db: DB = DB.shared,
		queue: DispatchQueue = .main,
		jsonOptions: JSONSerialization.ReadingOptions = .allowFragments,
		jsonTransformer: @escaping (Any) throws -> Any = { $0 },
		contextObject: Any? = nil,
		then handler: @escaping (DataResponse<T, AFError>, @escaping DB.SaveBlockWitCallback) -> Void
	) -> Self {
		let context = db.newBackgroundContext()
		let save: DB.SaveBlockWitCallback = { completion in
			context.perform {
				do {
					try context.save()
					queue.async {
						completion(nil)
					}
				} catch {
					queue.async {
						completion(error)
					}
				}
			}
		}

		let serializer = InsertResponseSerializer(
			jsonOptions: jsonOptions,
			jsonTransformer: jsonTransformer,
			context: context,
			type: type,
			contextObject: contextObject
		)

		return response(queue: queue, responseSerializer: serializer) { response in
			handler(response, save)
		}
	}
}
