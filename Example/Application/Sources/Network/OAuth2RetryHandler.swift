//
//  OAuth2RetryHandler.swift
//  Example
//
//  Created by David Jennes on 20/03/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Alamofire
import p2_OAuth2

class OAuth2RetryHandler: RequestRetrier, RequestAdapter {
	let loader: OAuth2DataLoader

	init(oauth2: OAuth2) {
		loader = OAuth2DataLoader(oauth2: oauth2)
	}

	/// Intercept 401 and do an OAuth2 authorization.
	public func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
		guard let response = request.task?.response as? HTTPURLResponse,
			response.statusCode == 401,
			let req = request.request else {
				completion(false, 0.0)
				return
		}

		// delete access token
		loader.oauth2.clientConfig.accessToken = nil

		var dataRequest = OAuth2DataRequest(request: req) { _ in }
		dataRequest.context = completion
		loader.enqueue(request: dataRequest)
		loader.attemptToAuthorize { authParams, _ in
			self.loader.dequeueAndApply { req in
				if let comp = req.context as? RequestRetryCompletion {
					comp(nil != authParams, 0.0)
				}
			}
		}
	}

	/// Sign the request with the access token.
	public func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
		guard nil != loader.oauth2.accessToken else {
			return urlRequest
		}
		return try urlRequest.signed(with: loader.oauth2)
	}
}
