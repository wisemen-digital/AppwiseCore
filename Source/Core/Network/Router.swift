//
//  Router.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Alamofire

public protocol Router: URLRequestConvertible {
	static var baseURLString: String { get }
	
	var method: HTTPMethod { get }
	var path: String { get }
	var params: Parameters? { get }
	var encoding: ParameterEncoding { get }
	
	var updateInterval: TimeInterval { get }
}

public extension Router {
	func asURLRequest() throws -> URLRequest {
		let url = try Self.baseURLString.asURL()
		
		var request = URLRequest(url: url.appendingPathComponent(path))
		request = try encoding.encode(request, with: params)
		request.httpMethod = method.rawValue
		
		return request
	}
	
	var method: HTTPMethod {
		return .get
	}
	
	var params: (Parameters?) {
		return nil
	}
	
	var encoding: ParameterEncoding {
		return JSONEncoding.default
	}
}

public extension Router {
	var updateInterval: TimeInterval {
		return 24*3600
	}
	
	var lastUpdated: TimeInterval {
		return Settings.shared.timestamp(router: self)
	}

	func shouldUpdate(completion: ((_ resource: Self, _ shouldUpdate: Bool) -> Void)) -> Void {
		let now = Date().timeIntervalSince1970

		// should update if more than 1 day ago
		let should = now - Settings.shared.timestamp(router: self) > updateInterval
		completion(self, should)
	}

	final func touch() {
		let now = Date().timeIntervalSince1970
		Settings.shared.setTimestamp(now, router: self)
	}
}