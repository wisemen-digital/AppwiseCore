//
//  Client+Request.swift
//  AppwiseCore
//
//  Created by David Jennes on 24/07/2018.
//

import Alamofire
import CocoaLumberjack
import CodableAlamofire

public extension Client {
	/// Shortcut method for building the request and loading the data.
	///
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter handler: The code to be executed once the request has finished.
	func requestData(
		_ request: RouterType,
		queue: DispatchQueue? = nil,
		then handler: @escaping (Alamofire.Result<Data>) -> Void
	) {
		buildRequest(request) { result in
			switch result {
			case let .success(request):
				request.responseData(queue: queue) { response in
					switch response.result {
					case .success:
						handler(response.result)
					case .failure(let error):
						let error = Self.extract(from: response, error: error)
						DDLogInfo(error.localizedDescription)
						handler(.failure(error))
					}
				}
			case .failure(let error):
				DDLogInfo("Error creating request: \(error.localizedDescription)")
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
	func requestJSON(
		_ request: RouterType,
		queue: DispatchQueue? = nil,
		options: JSONSerialization.ReadingOptions = .allowFragments,
		then handler: @escaping (Alamofire.Result<Any>) -> Void
	) {
		buildRequest(request) { result in
			switch result {
			case let .success(request):
				request.responseJSON(queue: queue, options: options) { response in
					switch response.result {
					case .success:
						handler(response.result)
					case .failure(let error):
						let error = Self.extract(from: response, error: error)
						DDLogInfo(error.localizedDescription)
						handler(.failure(error))
					}
				}
			case .failure(let error):
				DDLogInfo("Error creating request: \(error.localizedDescription)")
				handler(.failure(error))
			}
		}
	}

	/// Shortcut method for building the request, parsing the JSON and decoding it into an object.
	///
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	/// - parameter keyPath: The keyPath where object decoding should be performed. Default: `nil`.
	/// - parameter handler: The code to be executed once the request has finished.
	func requestJSONDecodable<T: Decodable>(
		_ request: RouterType,
		queue: DispatchQueue? = nil,
		keyPath: String? = nil,
		then handler: @escaping (Alamofire.Result<T>) -> Void
	) {
		buildRequest(request) { result in
			switch result {
			case let .success(request):
				request.responseDecodableObject(queue: queue, keyPath: keyPath) { (response: DataResponse<T>) in
					switch response.result {
					case .success:
						handler(response.result)
					case .failure(let error):
						let error = Self.extract(from: response, error: error)
						DDLogInfo(error.localizedDescription)
						handler(.failure(error))
					}
				}
			case .failure(let error):
				DDLogInfo("Error creating request: \(error.localizedDescription)")
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
		queue: DispatchQueue? = nil,
		encoding: String.Encoding? = nil,
		then handler: @escaping (Alamofire.Result<String>) -> Void
	) {
		buildRequest(request) { result in
			switch result {
			case let .success(request):
				request.responseString(queue: queue, encoding: encoding) { response in
					switch response.result {
					case .success:
						handler(response.result)
					case .failure(let error):
						let error = Self.extract(from: response, error: error)
						DDLogInfo(error.localizedDescription)
						handler(.failure(error))
					}
				}
			case .failure(let error):
				DDLogInfo("Error creating request: \(error.localizedDescription)")
				handler(.failure(error))
			}
		}
	}
}
