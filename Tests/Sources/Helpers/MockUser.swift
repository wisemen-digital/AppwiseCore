//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Foundation

struct MockUser: Decodable, Equatable {
	let id: Int
	let email: String
	let firstName: String
	let lastName: String?
}

extension MockUser {
	static func example() -> MockUser {
		guard let url = StubHelper.testBundle.url(forResource: "user", withExtension: "json") else {
			fatalError()
		}

		do {
			let data = try Data(contentsOf: url)
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			
			return try decoder.decode(Self.self, from: data)
		} catch {
			fatalError()
		}
	}
}
