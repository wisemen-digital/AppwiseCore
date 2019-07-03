//
//  Client+Insert.swift
//  AppwiseCore
//
//  Created by David Jennes on 24/07/2018.
//

import Alamofire
import CocoaLumberjack

public extension Client {
	// swiftlint:disable function_default_parameter_at_end
	/// Shortcut method for building the request, performing an insert, and saving the result.
	///
	/// - parameter request:        The router request type
	/// - parameter db:             The database to work in
	/// - parameter queue:          The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonSerializer: The response JSON serializer
	/// - parameter type:           The `Insertable` type that will be used in the serialization
	/// - parameter contextObject:  The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter handler:        The code to be executed once the request has finished.
	func requestInsert<T: Insertable>(
		_ request: RouterType,
		db: DB = DB.shared,
		queue: DispatchQueue? = nil,
		jsonSerializer: DataResponseSerializer<Any> = DataRequest.jsonResponseSerializer(),
		type: T.Type,
		contextObject: Any? = nil,
		then handler: @escaping (Alamofire.Result<T>) -> Void
	) {
		let responseHandler = { (response: DataResponse<T>, save: @escaping DB.SaveBlockWitCallback) in
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
					} catch let error {
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

		buildRequest(request) { result in
			switch result {
			case let .success(request):
				request.responseInsert(
					db: db,
					queue: queue,
					jsonSerializer: jsonSerializer,
					type: type,
					contextObject: contextObject,
					then: responseHandler
				)
			case .failure(let error):
				DDLogInfo("Error creating request: \(error.localizedDescription)")
				handler(.failure(error))
			}
		}
	}
}
