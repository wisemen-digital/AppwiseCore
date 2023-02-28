//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import AppwiseCore

enum MockRouter: Router {
	static let baseURLString: String = "https://does-not-exists.com"

	case user

	var path: String {
		switch self {
		case .user: return "user"
		}
	}
}
