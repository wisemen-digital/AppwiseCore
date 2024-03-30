//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Alamofire
import CocoaLumberjack

@available(iOS 13, *)
public extension Client {
	// swiftlint:disable function_default_parameter_at_end
	/// Shortcut method for building the request, performing an insert, and saving the result.
	///
	/// - parameter request:         The router request type
	/// - parameter type:            The `Insertable` type that will be used in the serialization
	/// - parameter db:              The database to work in
	/// - parameter jsonTransformer: The response JSON transformer
	/// - parameter contextObject:   The object to pass along to an import operation (see `ImportContext.object`)
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
	) async throws -> T {
		let task = self.request(request).serializingData(automaticallyCancelling: automaticallyCancelling)
		let data: Data = try await Self.transform(response: task.response)

		// use old decoding for Groot
		let json = try JSONSerialization.jsonObject(with: data, options: jsonOptions)
		let transformedJSON = try jsonTransformer(json)

		// actually insert (use non-async function for now, until we switch around)
		return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) in
			Self.insert(json: transformedJSON, into: db, queue: .main, contextObject: contextObject) { result in
				continuation.resume(with: result)
			}
		}
	}
}
