//
//  Client.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
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
}

public extension Client {
	/// Shortcut method for creating a request
	///
	/// - parameter request: The router request type
	///
	/// - returns: The data request object
	func request(_ request: RouterType) -> DataRequest {
		return sessionManager.request(request).validate()
	}
}
