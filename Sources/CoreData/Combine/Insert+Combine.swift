//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import CocoaLumberjack
import Combine

@available(iOS 13.0, *)
public extension Client {
	// swiftlint:disable function_default_parameter_at_end
	/// Shortcut method for building the request, performing an insert, and saving the result.
	///
	/// - parameter request:        The router request type
	/// - parameter type:           The `Insertable` type that will be used in the serialization
	/// - parameter db:             The database to work in
	/// - parameter queue:          The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonSerializer: The response JSON serializer
	/// - parameter contextObject:  The object to pass along to an import operation (see `ImportContext.object`)
	func requestInsert<T: Insertable>(
		_ request: RouterType,
		of type: T.Type = T.self,
		db: DB = DB.shared,
		queue: DispatchQueue = .main,
		jsonOptions: JSONSerialization.ReadingOptions = .allowFragments,
		jsonTransformer: @escaping (Any) throws -> Any = { $0 },
		contextObject: Any? = nil
	) -> Return.Response<T> {
		self.request(request)
			.responseInsert(
				of: type,
				db: db,
				queue: queue,
				jsonOptions: jsonOptions,
				jsonTransformer: jsonTransformer,
				contextObject: contextObject
			)
			.map { response in
				switch response.result {
				case .success(let value):
					let context = DB.shared.view
					var result: Result<T, Error>!

					context.performAndWait {
						do {
							let mainValue = try value.inContext(context)
							result = .success(mainValue)
						} catch {
							result = .failure(error)
						}
					}

					return result
				case .failure(let error):
					if let afError = error as? AFError {
						let newResponse = response.transform(result: Result<T, AFError>.failure(afError))
						let newError = Self.extract(from: newResponse, error: afError)
						return Result<T, Error>.failure(newError)
					} else {
						return Result<T, Error>.failure(error)
					}
				}
			}
			.eraseToAnyPublisher()
	}
}
