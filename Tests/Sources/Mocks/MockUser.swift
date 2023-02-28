//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Foundation

struct MockUser: Codable, Equatable {
	let id: Int
	let email: String
	let firstName: String
	let lastName: String?
}

extension MockUser {
	static let `default` = MockUser(
		id: 1,
		email: "doesnotexists@unknown.com",
		firstName: "John",
		lastName: nil
	)
}
