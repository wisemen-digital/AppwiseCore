//
//  Client.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Alamofire

/// Representation of network client, works in conjunction with the `Router` protocol. The
/// router will provide the requests, the client (this) will peform the actual calls and
/// process the responses.
public protocol Client {
	/// The router type for this client
	associatedtype RouterType: Router

	/// A client is a singleton
	static var shared: Self { get }

	/// The AlamoFire session manager for this client
	var sessionManager: SessionManager { get }

	/// Extract a readable error from the response in case of an error.
	///
	/// - parameter response: The data response
	/// - parameter error: The existing error
	///
	/// - returns: An error with the message from the response (see `ClientError`), or the existing error
	static func extract<T>(from response: DataResponse<T>, error: Error) -> Error
}

public extension Client {
	/// Shortcut method for creating a request
	///
	/// - parameter request: The router request type
	///
	/// - returns: The data request object
	func request(_ request: RouterType) -> DataRequest {
		let group = DispatchGroup()
		var dataRequest: DataRequest?

		group.enter()
		request.asURLRequest(with: sessionManager) { result in
			group.leave()
			dataRequest = result.value
		}

		group.wait()
		guard let result = dataRequest else {
			fatalError("Unable to create data request")
		}
		return result.validate()
	}

	/// Shortcut method for creating a request
	///
	/// - parameter request: The router request type
	/// - parameter completion: The closure to call when finished
	/// - parameter result: The resulting data request (or an error)
	func buildRequest(_ request: RouterType, completion: @escaping (_ result: Result<DataRequest>) -> Void) {
		request.asURLRequest(with: sessionManager) { result in
			switch result {
			case let .success(request):
				completion(.success(request.validate()))
			default:
				completion(result)
			}
		}
	}
}
