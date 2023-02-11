//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Alamofire

@available(iOS 13, *)
extension DataRequest {
	/// Adds a handler to be called once the request has finished.
	///
	/// - parameter type:              The `Insertable` type that will be used in the serialization
	/// - parameter db:                The database to work in
	/// - parameter queue:             The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonOptions:       JSON decoder options
	/// - parameter jsonTransformer:   The response JSON transformer
	///
	/// - returns: the response
	func responseInsert<T: Insertable>(
		of type: T.Type = T.self,
		db: DB = DB.shared,
		jsonOptions: JSONSerialization.ReadingOptions = .allowFragments,
		jsonTransformer: @escaping (Any) throws -> Any = { $0 },
		contextObject: Any? = nil,
		automaticallyCancelling: Bool = false
	) async -> DataResponse<T, AFError> {
		let context = db.newBackgroundContext()
		let save: DB.SaveBlockWitCallback = { completion in
			context.perform {
				do {
					try context.save()
					completion(nil)
				} catch {
					completion(error)
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

		let task = serializingResponse(using: serializer, automaticallyCancelling: automaticallyCancelling)
		let response = await task.response

		switch response.result {
		case .success(let value):
			let saveResult = await withCheckedContinuation { (continuation: CheckedContinuation<Result<Void, Error>, Never>) in
				save { error in
					if let error = error {
						continuation.resume(returning: .failure(error))
					} else {
						continuation.resume(returning: .success(()))
					}
				}
			}

			switch saveResult {
			case .success:
				return response
			case .failure(let error):
				return response.mapError { _ in AFError.responseSerializationFailed(reason: .customSerializationFailed(error: error)) }
			}
		case .failure:
			return response
		}
	}
}
