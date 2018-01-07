//
//  Router.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Alamofire

/// This protocol represents the elements needed to create an URL request, usually in combination
/// with a network client. The implementation for a router is usually an enum.
public protocol Router: URLRequestConvertible {
	/// The base url for this router, all paths will be relative to this url.
	static var baseURLString: String { get }

	/// The HTTP method (get, post, ...). Default: .get
	var method: HTTPMethod { get }

	/// The path relative to the base URL
	var path: String { get }

	/// The request headers (dictionary). Default: empty dictionary
	var headers: [String: String] { get }

	/// The parameters for a request, will be encoded using the `encoding`. Default: empty list
	var params: Parameters? { get }

	/// The encoding to apply to the parameters. Default: `JSONEncoding`
	var encoding: ParameterEncoding { get }

	/// The update interval that should be applied to this request. Default: 1 day
	var updateInterval: TimeInterval { get }
}

/// Default implementation
public extension Router {
	func asURLRequest() throws -> URLRequest {
		let baseURL = try Self.baseURLString.asURL()
		guard let url = URL(string: path, relativeTo: baseURL) else {
			throw AFError.invalidURL(url: path)
		}
		
		var request = URLRequest(url: url)
		request = try encoding.encode(request, with: params)
		request.httpMethod = method.rawValue
		for (header, value) in headers {
			request.addValue(value, forHTTPHeaderField: header)
		}
		
		return request
	}
	
	var method: HTTPMethod {
		return .get
	}
	
	var headers: [String: String] {
		return [:]
	}
	
	var params: (Parameters?) {
		return nil
	}
	
	var encoding: ParameterEncoding {
		return JSONEncoding.default
	}
}

public extension Router {
	/// Default update interval is 1 day
	var updateInterval: TimeInterval {
		return 24*3600
	}

	/// When the request was last performed (defaults to timestamp 0)
	var lastUpdated: TimeInterval {
		return Settings.shared.timestamp(router: self)
	}

	/// Checks wether a resource should be updated
	///
	/// - parameter completion: The completion block to call when you have the update related information
	/// - parameter resource: The router item to check for information
	/// - parameter shouldUpdate: True if the resource should be updated or not
	func shouldUpdate(completion: ((_ resource: Self, _ shouldUpdate: Bool) -> Void)) {
		let now = Date().timeIntervalSince1970

		// should update if more than 1 day ago
		let should = now - Settings.shared.timestamp(router: self) > updateInterval
		completion(self, should)
	}

	func touch() {
		let now = Date().timeIntervalSince1970
		Settings.shared.setTimestamp(now, router: self)
	}
}
