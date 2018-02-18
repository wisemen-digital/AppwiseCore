//
//  APIRouter.swift
//  Example
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Alamofire
import AppwiseCore

enum APIRouter: AppwiseCore.Router {
	static var baseURLString = env(.dev("https://test.com"),
	                               .stg("https://test.com"),
	                               .prd("https://test.com"))

	case test
	case tester(user: User)
}

extension APIRouter {
	var path: String {
		switch self {
		case .test:
			return "/test/test"
		case let .tester(user):
			return "/tester/\(user.id)"
		}
	}

	var method: HTTPMethod {
		switch self {
		case .test:
			return .post
		default:
			return .get
		}
	}

	var params: Parameters? {
		switch self {
		case .test:
			return [
				"test": 1
			]
		default:
			return nil
		}
	}
}
