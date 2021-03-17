//
//  Router.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Alamofire

public extension Result {
	func asVoid() -> Result<Void> {
		map { _ in }
	}

	/// Returns a new cancelled result.
	static var cancelled: Result {
		.failure(Cancelled())
	}

	/// Returns `true` if this result is cancelled.
	var isCancelled: Bool {
		error is Cancelled
	}

	public struct Cancelled: Error {}
}
