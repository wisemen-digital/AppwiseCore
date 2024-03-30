//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Alamofire
import CocoaLumberjack

@available(iOS 13, *)
public extension Client {
	/// Shortcut method for building the request and loading the response (ignoring data).
	///
	/// - parameter request: The router request type
	/// - parameter automaticallyCancelling: Bool determining whether or not the request should be cancelled when the enclosing async context is cancelled.
	///
	/// - returns: the result
	func requestVoid(
		_ request: RouterType,
		automaticallyCancelling: Bool = false
	) async throws {
		let task = self.request(request).serializingResponse(using: PassthroughResponseSerializer(), automaticallyCancelling: automaticallyCancelling)
		return try await Self.transform(response: task.response)
	}

	/// Shortcut method for building the request and loading the data.
	///
	/// - parameter request: The router request type
	/// - parameter automaticallyCancelling: Bool determining whether or not the request should be cancelled when the enclosing async context is cancelled.
	///
	/// - returns: the result
	func requestData(
		_ request: RouterType,
		automaticallyCancelling: Bool = false
	) async throws -> Data {
		let task = self.request(request).serializingData(automaticallyCancelling: automaticallyCancelling)
		return try await Self.transform(response: task.response)
	}

	/// Shortcut method for building the request and parsing the JSON.
	///
	/// - parameter request: The router request type
	/// - parameter options: The JSON serialization reading options. Defaults to `.allowFragments`.
	/// - parameter automaticallyCancelling: Bool determining whether or not the request should be cancelled when the enclosing async context is cancelled.
	///
	/// - returns: the result
	@available(*, deprecated, message: "Will be removed in Alamofire 6. Use `Decodable` instead.")
	func requestJSON(
		_ request: RouterType,
		options: JSONSerialization.ReadingOptions = .allowFragments,
		automaticallyCancelling: Bool = false
	) async throws -> Any {
		let task = self.request(request).serializingResponse(using: JSONResponseSerializer(options: options), automaticallyCancelling: automaticallyCancelling)
		return try await Self.transform(response: task.response)
	}

	/// Shortcut method for building the request, parsing the JSON and decoding it into an object.
	///
	/// - parameter type: The type to decode
	/// - parameter request: The router request type
	/// - parameter decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
	/// - parameter automaticallyCancelling: Bool determining whether or not the request should be cancelled when the enclosing async context is cancelled.
	///
	/// - returns: the result
	func requestDecodable<T: Decodable>(
		_ request: RouterType,
		of type: T.Type = T.self,
		decoder: DataDecoder = JSONDecoder(),
		automaticallyCancelling: Bool = false
	) async throws -> T {
		let task = self.request(request).serializingDecodable(type, automaticallyCancelling: automaticallyCancelling, decoder: decoder)
		return try await Self.transform(response: task.response)
	}

	/// Shortcut method for building the request and parsing the String.
	///
	/// - parameter request:  The router request type
	/// - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
	///                       server response, falling back to the default HTTP default character set,
	///                       ISO-8859-1.
	/// - parameter automaticallyCancelling: Bool determining whether or not the request should be cancelled when the enclosing async context is cancelled.
	///
	/// - returns: the result
	func requestString(
		_ request: RouterType,
		encoding: String.Encoding? = nil,
		automaticallyCancelling: Bool = false
	) async throws -> String {
		let task = self.request(request).serializingString(automaticallyCancelling: automaticallyCancelling, encoding: encoding)
		return try await Self.transform(response: task.response)
	}
}

// MARK: - Helpers

extension Client {
	static func transform<T>(response: DataResponse<T, AFError>) throws -> T {
		switch response.result {
		case .success(let data):
			return data
		case .failure(let error):
			let error = extract(from: response, error: error)
			DDLogInfo("\(error.localizedDescription)")
			throw error
		}
	}
}

/// A `ResponseSerializer` which performs no serialization on incoming `Data`.
private final class PassthroughResponseSerializer: ResponseSerializer {
	let dataPreprocessor: DataPreprocessor
	let emptyResponseCodes: Set<Int>
	let emptyRequestMethods: Set<HTTPMethod>

	init(
		dataPreprocessor: DataPreprocessor = PassthroughResponseSerializer.defaultDataPreprocessor,
		emptyResponseCodes: Set<Int> = PassthroughResponseSerializer.defaultEmptyResponseCodes,
		emptyRequestMethods: Set<HTTPMethod> = PassthroughResponseSerializer.defaultEmptyRequestMethods
	) {
		self.dataPreprocessor = dataPreprocessor
		self.emptyResponseCodes = emptyResponseCodes
		self.emptyRequestMethods = emptyRequestMethods
	}

	// Based on `StringResponseSerializer`
	func serialize(request: URLRequest?, response: HTTPURLResponse?, data: Data?, error: Error?) throws {
		if let error {
			throw error
		}

		guard let data, !data.isEmpty else {
			guard emptyResponseAllowed(forRequest: request, response: response) else {
				throw AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength)
			}
			return
		}
	}
}
