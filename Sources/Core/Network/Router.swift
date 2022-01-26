//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire

public typealias MultipartBuilder = (MultipartFormData) -> Void

/// This protocol represents the elements needed to create an URL request, usually in combination
/// with a network client. The implementation for a router is usually an enum.
public protocol Router: URLRequestConvertible, URLConvertible {
	/// The base url for this router, all paths will be relative to this url.
	static var baseURLString: String { get }

	/// The HTTP method (get, post, ...). Optional, default: .get
	var method: HTTPMethod { get }

	/// The path relative to the base URL. Required
	var path: String { get }

	/// The request headers (dictionary). Optional, default: nil
	var headers: HTTPHeaders? { get }

	/// The parameters for a request, will be encoded using the `encoding`. Optional, default: nil
	var params: Parameters? { get }

	/// The parameters for a request, will be encoded using the `encoding`. Optional, default: nil
	var anyParams: Any? { get }

	/// The encoding to apply to the parameters. Optional, default: `JSONEncoding`
	var encoding: ParameterEncoding { get }

	/// The closure to build multipart components if needed. Optional, default: nil
	var multipart: MultipartBuilder? { get }

	/// The update interval that should be applied to this request. Optional, default: 1 day
	var updateInterval: TimeInterval { get }
}

// MARK: - URLConvertible

public extension Router {
	func asURL() throws -> URL {
		let baseURL = try Self.baseURLString.asURL()
		guard let url = URL(string: path, relativeTo: baseURL) else {
			throw AFError.invalidURL(url: path)
		}

		return url
	}
}

// MARK: - URLRequestConvertible

public extension Router {
	/// Shortcut for creating an URLRequest as it would be used in a `DataRequest`
	func asURLRequest() throws -> URLRequest {
		precondition(multipart == nil, "Cannot build request, it has a multipart constructor.")
		return try buildURLRequest()
	}

	/// Build a data request for this route.
	///
	/// Warning: this starts the request!
	///
	/// - parameter session: The session used to construct the data request
	func makeDataRequest(session: Session) -> DataRequest {
		let request: URLRequest
		do {
			request = try buildURLRequest()
		} catch {
			fatalError("Error building request: \(error)")
		}

		if let multipart = multipart {
			return session.upload(multipartFormData: multipart, with: request)
		} else {
			return session.request(request)
		}
	}

	@available(*, unavailable, renamed: "makeDataRequest(session:)")
	func asURLRequest(with sessionManager: Session, completion: @escaping (_ result: Result<DataRequest, Error>) -> Void) {
		fatalError("unavailable")
	}

	private func buildURLRequest() throws -> URLRequest {
		let params = self.params ?? anyParams

		var request = try URLRequest(url: self, method: method, headers: headers)
		if let encoding = encoding as? JSONEncoding {
			if let params = params as? Encodable {
				request = try JSONParameterEncoder().encode(AnyEncodable(params), into: request)
			} else {
				request = try encoding.encode(request, withJSONObject: params)
			}
		} else if let params = params as? Parameters {
			request = try encoding.encode(request, with: params)
		} else if params != nil {
			preconditionFailure("Cannot encode non-dictionary when Router encoding is not JSON")
		}

		return request
	}
}

// MARK: - Default implementation

public extension Router {
	var method: HTTPMethod {
		.get
	}

	var headers: HTTPHeaders? {
		nil
	}

	var params: Parameters? {
		nil
	}

	var anyParams: Any? {
		nil
	}

	var encoding: ParameterEncoding {
		JSONEncoding.default
	}

	var multipart: MultipartBuilder? {
		nil
	}
}

public extension Router {
	/// Default update interval is 1 day
	var updateInterval: TimeInterval {
		24 * 3_600
	}

	/// When the request was last performed (defaults to timestamp 0)
	var lastUpdated: TimeInterval {
		Settings.shared.timestamp(router: self)
	}

	/// Checks wether a resource should be updated
	///
	/// - parameter completion: The completion block to call when you have the update related information
	/// - parameter resource: The router item to check for information
	/// - parameter shouldUpdate: True if the resource should be updated or not
	func shouldUpdate(completion: (_ resource: Self, _ shouldUpdate: Bool) -> Void) {
		let now = Date().timeIntervalSince1970

		// should update if more than 1 day ago
		let should = now - Settings.shared.timestamp(router: self) > updateInterval
		completion(self, should)
	}

	/// Set the last updated timestamp for this resource
	///
	/// - parameter timestamp: The date to set the timestamp to. Defaults to now.
	func touch(_ timestamp: Date = Date()) {
		Settings.shared.setTimestamp(timestamp.timeIntervalSince1970, router: self)
	}
}
