//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import CocoaLumberjack

public extension Client {
	// swiftlint:disable function_default_parameter_at_end
	/// Shortcut method for building the request, performing an insert, and saving the result.
	///
	/// - parameter request:        The router request type
	/// - parameter type:           The `Insertable` type that will be used in the serialization
	/// - parameter db:             The database to work in
	/// - parameter queue:          The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonSerializer: The response JSON serializer
	/// - parameter jsonTransformer: The response JSON transformer
	/// - parameter contextObject:  The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter handler:        The code to be executed once the request has finished.
	func requestInsert<T: Insertable>(
		_ request: RouterType,
		of type: T.Type = T.self,
		db: DB = DB.shared,
		queue: DispatchQueue = .main,
		jsonOptions: JSONSerialization.ReadingOptions = .allowFragments,
		jsonTransformer: @escaping (Any) throws -> Any = { $0 },
		contextObject: Any? = nil,
		then handler: @escaping (Result<T, Error>) -> Void
	) {
		let responseHandler = { (response: DataResponse<T, AFError>, save: @escaping DB.SaveBlockWitCallback) in
			switch response.result {
			case .success(let value):
				save { error in
					// cast the value to the main context
					do {
						if let error = error {
							throw error
						} else {
							let mainValue = try value.inContext(db.main)
							handler(.success(mainValue))
						}
					} catch {
						DDLogInfo("Error saving result: \(error.localizedDescription)")
						handler(.failure(error))
					}
				}
			case .failure(let error):
				let error = Self.extract(from: response, error: error)
				DDLogInfo(error.localizedDescription)
				handler(.failure(error))
			}
		}

		self.request(request).responseInsert(
			of: type,
			db: db,
			queue: queue,
			jsonOptions: jsonOptions,
			jsonTransformer: jsonTransformer,
			contextObject: contextObject,
			then: responseHandler
		)
	}

	@available(*, deprecated, renamed: "requestInsert(_:of:db:queue:jsonOptions:jsonTransformer:contextObject:then:)")
	func requestInsert<T: Insertable>(
		_ request: RouterType,
		db: DB = DB.shared,
		queue: DispatchQueue = .main,
		jsonTransformer: @escaping (Any) throws -> Any,
		type: T.Type,
		contextObject: Any? = nil,
		then handler: @escaping (Result<T, Error>) -> Void
	) {
		requestInsert(request, of: type, db: db, queue: queue, jsonTransformer: jsonTransformer, contextObject: contextObject, then: handler)
	}
}

@available(iOS 13, *)
public extension Client {
	// swiftlint:disable function_default_parameter_at_end
	/// Shortcut method for building the request, performing an insert, and saving the result.
	///
	/// - parameter request:        The router request type
	/// - parameter type:           The `Insertable` type that will be used in the serialization
	/// - parameter db:             The database to work in
	/// - parameter jsonSerializer: The response JSON serializer
	/// - parameter jsonTransformer: The response JSON transformer
	/// - parameter contextObject:  The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter automaticallyCancelling: Bool determining whether or not the request should be cancelled when the enclosing async context is cancelled.
	///
	/// - returns: the result
	func requestInsert<T: Insertable>(
		_ request: RouterType,
		of type: T.Type = T.self,
		db: DB = DB.shared,
		jsonOptions: JSONSerialization.ReadingOptions = .allowFragments,
		jsonTransformer: @escaping (Any) throws -> Any = { $0 },
		contextObject: Any? = nil,
		automaticallyCancelling: Bool = false
	) async -> Result<T, Error> {
		let response = await self.request(request).responseInsert(
			of: type,
			db: db,
			jsonOptions: jsonOptions,
			jsonTransformer: jsonTransformer,
			contextObject: contextObject,
			automaticallyCancelling: automaticallyCancelling
		)

		switch response.result {
		case .success(let value):
			do {
				return try await MainActor.run { .success(try value.inContext(db.main)) }
			} catch {
				DDLogInfo(error.localizedDescription)
				return .failure(error)
			}
		case .failure(let error):
			let error = Self.extract(from: response, error: error)
			DDLogInfo(error.localizedDescription)
			return .failure(error)
		}
	}
}
