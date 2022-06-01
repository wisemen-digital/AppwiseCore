//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import Combine

@available(iOS 13.0, *)
public enum Return {
	public typealias Response<T> = AnyPublisher<Result<T, Error>, Never>
}

@available(iOS 13.0, *)
public extension Client {
	/// Shortcut method for building the request, parsing the JSON and decoding it into an object.
	///
	/// - parameter type: The type to decode
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
	func requestDecodable<T: Decodable>(
		_ request: RouterType,
		of type: T.Type = T.self,
		queue: DispatchQueue = .main,
		decoder: DataDecoder = JSONDecoder()
	) -> Return.Response<T> {
		self.request(request)
			.publishDecodable(type: type, queue: queue, decoder: decoder)
			.map { response in response.mapError { Self.extract(from: response, error: $0) }.result }
			.share()
			.eraseToAnyPublisher()
	}

	/// Shortcut method for building the request and loading the data.
	///
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	func requestData(
		_ request: RouterType,
		queue: DispatchQueue = .main
	) -> Return.Response<Data> {
		self.request(request)
			.publishData()
			.map { response in response.mapError { Self.extract(from: response, error: $0) }.result }
			.share()
			.eraseToAnyPublisher()
	}


	/// Shortcut method for building the request and parsing the JSON.
	///
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter options: The JSON serialization reading options. Defaults to `.allowFragments`.
	/// - parameter handler: The code to be executed once the request has finished.

	@available(*, deprecated, message: "Will be removed in Alamofire 6. Use decodable instead.")
	func requestJSON(
		_ request: RouterType,
		queue: DispatchQueue = .main,
		options: JSONSerialization.ReadingOptions = .allowFragments
	) -> Return.Response<Any> {
		self.request(request)
			.publishResponse(using: JSONResponseSerializer(options: options), on: queue)
			.map { response in response.mapError { Self.extract(from: response, error: $0) }.result }
			.share()
			.eraseToAnyPublisher()
	}

	/// Shortcut method for building the request and parsing the JSON.
	///
	/// - parameter request:  The router request type
	/// - parameter queue:    The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
	///                       server response, falling back to the default HTTP default character set,
	///                       ISO-8859-1.
	func requestString(
		_ request: RouterType,
		queue: DispatchQueue = .main,
		encoding: String.Encoding? = nil
	) -> Return.Response<String> {
		self.request(request)
			.publishString()
			.map { response in response.mapError { Self.extract(from: response, error: $0) }.result }
			.share()
			.eraseToAnyPublisher()
	}
}
