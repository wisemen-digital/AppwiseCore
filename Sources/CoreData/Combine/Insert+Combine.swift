//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import CocoaLumberjack
import Combine

@available(iOS 13.0, *)
public extension Client {
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
	) -> AnyPublisher<Result<T, Error>, Never> {
		var dataRequest: DataRequest?
		return Future { promise in
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
								promise(.success(.success(mainValue)))
							}
						} catch {
							DDLogInfo("Error saving result: \(error.localizedDescription)")
							promise(.success(.failure(error)))
						}
					}
				case .failure(let error):
					let error = Self.extract(from: response, error: error)
					DDLogInfo(error.localizedDescription)
					promise(.success(.failure(error)))
				}
			}

			dataRequest = self.request(request).responseInsert(
				of: type,
				db: db,
				queue: queue,
				jsonOptions: jsonOptions,
				jsonTransformer: jsonTransformer,
				contextObject: contextObject,
				then: responseHandler
			)
		}
		.handleEvents(receiveCancel: { dataRequest?.cancel() })
		.eraseToAnyPublisher()
	}
}
