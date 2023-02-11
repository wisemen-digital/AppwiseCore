//
// AppwiseCore
// Copyright © 2023 Wisemen
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
				return try await MainActor.run { try .success(value.inContext(db.view)) }
			} catch {
				DDLogInfo(error.localizedDescription)
				return .failure(error)
			}
		case .failure:
			return Self.transform(response: response)
		}
	}
}
