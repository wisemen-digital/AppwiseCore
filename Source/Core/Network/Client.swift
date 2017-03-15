//
//  Client.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Alamofire

public protocol Client {
	associatedtype RouterType: Router
	
	static var shared: Self { get }
	var sessionManager: SessionManager { get }
}

public extension Client {
	func request(_ request: RouterType) -> DataRequest {
		return sessionManager.request(request).validate()
	}
}
