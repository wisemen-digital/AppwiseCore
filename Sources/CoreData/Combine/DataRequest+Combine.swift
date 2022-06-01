//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import CocoaLumberjack
import Combine
import CoreData

@available(iOS 13, *)
public extension DataRequest {
	@discardableResult
	func responseInsert<T: Insertable>(
		of type: T.Type = T.self,
		db: DB = DB.shared,
		queue: DispatchQueue = .main,
		jsonOptions: JSONSerialization.ReadingOptions = .allowFragments,
		jsonTransformer: @escaping (Any) throws -> Any = { $0 },
		contextObject: Any? = nil
	) -> AnyPublisher<DataResponse<T, Error>, Never> {
		let context = db.newBackgroundContext()
		let serializer = InsertResponseSerializer(
			jsonOptions: jsonOptions,
			jsonTransformer: jsonTransformer,
			context: context,
			type: type,
			contextObject: contextObject
		)

		return publishResponse(using: serializer)
			.map { response in response.mapError { $0 as Error } }
			.flatMap { response -> AnyPublisher<DataResponse<T, Error>, Never> in
				switch response.result {
				case .success:
					return Future<DataResponse<T, Error>, Never> { promise in
						context.perform {
							do {
								try context.save()
								queue.async { promise(.success(response)) }
							} catch {
								DDLogInfo("Error saving result: \(error.localizedDescription)")
								let newResponse = response.transform(result: Result<T, Error>.failure(error))
								queue.async { promise(.success(newResponse)) }
							}
						}
					}
					.eraseToAnyPublisher()
				case .failure:
					return Just(response).eraseToAnyPublisher()
				}
			}
			.share()
			.eraseToAnyPublisher()
	}
}

extension DataResponse {
	func transform<S, F>(result: Result<S, F>) -> DataResponse<S, F> {
		.init(
			request: request,
			response: response,
			data: data,
			metrics: metrics,
			serializationDuration: serializationDuration,
			result: result
		)
	}
}
