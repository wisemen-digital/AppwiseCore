//
// AppwiseCore
// Copyright © 2022 Appwise
//

#if canImport(Combine)
import Alamofire
import Combine

@available(iOS 13.0, *)
public extension Client {
	typealias Publisher<T> = Publishers.HandleEvents<Future<T, Error>>

	/// Shortcut method for building the request and loading the data.
	///
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	func requestVoid(
		_ request: RouterType,
		queue: DispatchQueue = .main
	) -> Publisher<Void> {
		var dataRequest: DataRequest?
		return Future { promise in
			dataRequest = self.requestVoid(request, queue: queue, then: promise)
		}
		.handleEvents(receiveCancel: { dataRequest?.cancel() })
	}

	/// Shortcut method for building the request and loading the data.
	///
	/// - parameter request: The router request type
	/// - parameter queue:   The queue on which the deserializer (and your completion handler) is dispatched.
	func requestData(
		_ request: RouterType,
		queue: DispatchQueue = .main
	) -> Publisher<Data> {
		var dataRequest: DataRequest?
		return Future { promise in
			dataRequest = self.requestData(request, queue: queue, then: promise)
		}
		.handleEvents(receiveCancel: { dataRequest?.cancel() })
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
	) -> Publisher<Any> {
		var dataRequest: DataRequest?
		return Future { promise in
			dataRequest = self.requestJSON(request, queue: queue, options: options, then: promise)
		}
		.handleEvents(receiveCancel: { dataRequest?.cancel() })
	}

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
	) -> Publisher<T> {
		var dataRequest: DataRequest?
		return Future { promise in
			dataRequest = self.requestDecodable(request, of: type, queue: queue, decoder: decoder, then: promise)
		}
		.handleEvents(receiveCancel: { dataRequest?.cancel() })
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
	) -> Publisher<String> {
		var dataRequest: DataRequest?
		return Future { promise in
			dataRequest = self.requestString(request, queue: queue, encoding: encoding, then: promise)
		}
		.handleEvents(receiveCancel: { dataRequest?.cancel() })
	}
}
#endif
