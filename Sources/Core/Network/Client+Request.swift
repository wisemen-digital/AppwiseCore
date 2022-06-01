//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import CocoaLumberjack

public extension Client {
	/// Shortcut method for building the request and loading the data.
	///
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter handler: The code to be executed once the request has finished.
	func requestData(
		_ request: RouterType,
		queue: DispatchQueue = .main,
		then handler: @escaping (Result<Data, Error>) -> Void
	) {
		self.request(request).responseData(queue: queue) { response in
			switch response.result {
			case .success(let data):
				handler(.success(data))
			case .failure(let error):
				let error = Self.extract(from: response, error: error)
				DDLogInfo(error.localizedDescription)
				handler(.failure(error))
			}
		}
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
		options: JSONSerialization.ReadingOptions = .allowFragments,
		then handler: @escaping (Result<Any, Error>) -> Void
	) {
		self.request(request).responseJSON(queue: queue, options: options) { response in
			switch response.result {
			case .success(let data):
				handler(.success(data))
			case .failure(let error):
				let error = Self.extract(from: response, error: error)
				DDLogInfo(error.localizedDescription)
				handler(.failure(error))
			}
		}
	}

	/// Shortcut method for building the request, parsing the JSON and decoding it into an object.
	///
	/// - parameter type: The type to decode
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter decoder: `DataDecoder` to use to decode the response. `JSONDecoder()` by default.
	/// - parameter handler: The code to be executed once the request has finished.
	func requestDecodable<T: Decodable>(
		_ request: RouterType,
		of type: T.Type = T.self,
		queue: DispatchQueue = .main,
		decoder: DataDecoder = JSONDecoder(),
		then handler: @escaping (Result<T, Error>) -> Void
	) {
		self.request(request).responseDecodable(of: type, queue: queue, decoder: decoder) { response in
			switch response.result {
			case .success(let data):
				handler(.success(data))
			case .failure(let error):
				let error = Self.extract(from: response, error: error)
				DDLogInfo(error.localizedDescription)
				handler(.failure(error))
			}
		}
	}

	/// Shortcut method for building the request and parsing the JSON.
	///
	/// - parameter request:  The router request type
	/// - parameter queue:    The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the
	///                       server response, falling back to the default HTTP default character set,
	///                       ISO-8859-1.
	/// - parameter handler:  The code to be executed once the request has finished.
	func requestString(
		_ request: RouterType,
		queue: DispatchQueue = .main,
		encoding: String.Encoding? = nil,
		then handler: @escaping (Result<String, Error>) -> Void
	) {
		self.request(request).responseString(queue: queue, encoding: encoding) { response in
			switch response.result {
			case .success(let data):
				handler(.success(data))
			case .failure(let error):
				let error = Self.extract(from: response, error: error)
				DDLogInfo(error.localizedDescription)
				handler(.failure(error))
			}
		}
	}
}
