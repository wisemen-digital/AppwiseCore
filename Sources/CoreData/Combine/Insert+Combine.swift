//
// AppwiseCore
// Copyright © 2022 Appwise
//

#if canImport(Combine)
import Alamofire
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
	) -> Publisher<T> {
		var dataRequest: DataRequest?
		return Future { promise in
			dataRequest = self.requestInsert(request, of: type, db: db, queue: queue, jsonOptions: jsonOptions, jsonTransformer: jsonTransformer, contextObject: contextObject, then: promise)
		}
		.handleEvents(receiveCancel: { dataRequest?.cancel() })
	}
}
#endif
