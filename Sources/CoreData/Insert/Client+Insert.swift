//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Alamofire
import CocoaLumberjack

public extension Client {
	// swiftlint:disable function_default_parameter_at_end
	/// Shortcut method for building the request, performing an insert, and saving the result.
	///
	/// - parameter request:         The router request type
	/// - parameter type:            The `Insertable` type that will be used in the serialization
	/// - parameter db:              The database to work in
	/// - parameter queue:           The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter jsonTransformer: The response JSON transformer
	/// - parameter contextObject:   The object to pass along to an import operation (see `ImportContext.object`)
	/// - parameter handler:         The code to be executed once the request has finished.
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
		requestData(request, queue: queue) { result in
			switch result {
			case .success(let data):
				do {
					// use old decoding for Groot
					let json = try JSONSerialization.jsonObject(with: data, options: jsonOptions)
					let transformedJSON = try jsonTransformer(json)
					Self.insert(json: transformedJSON, into: db, queue: queue, contextObject: contextObject, then: handler)
				} catch {
					DDLogError(error.localizedDescription)
					handler(.failure(error))
				}
			case .failure(let error):
				handler(.failure(error))
			}
		}
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
	// swiftlint:enable function_default_parameter_at_end
}

// MARK: - Helpers

extension Client {
	static func insert<T: Insertable>(
		json: Any,
		into db: DB,
		queue: DispatchQueue,
		contextObject: Any?,
		then handler: @escaping (Result<T, Error>) -> Void
	) {
		db.operation(queue: queue) { context, save in
			do {
				let value: T = try T.insert(from: json, in: context)

				if let value = value as? Importable {
					let importContext = ImportContext(moc: context, object: contextObject)
					try value.didImport(from: json, in: importContext)
				}

				save { error in
					afterInsert(value: value, error: error, db: db, then: handler)
				}
			} catch {
				handler(.failure(error))
			}
		}
	}

	/// cast the value to the main context if we can
	static func afterInsert<T: Insertable>(value: T, error: Error?, db: DB, then handler: @escaping (Result<T, Error>) -> Void) {
		do {
			if let error {
				throw error
			} else {
				let mainValue = try value.inContext(db.view)
				handler(.success(mainValue))
			}
		} catch {
			DDLogError("Error saving result: \(error.localizedDescription)")
			handler(.failure(error))
		}
	}
}
