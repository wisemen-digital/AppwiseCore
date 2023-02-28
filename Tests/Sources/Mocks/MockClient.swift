//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import AppwiseCore

final class MockClient: Client {
	typealias RouterType = MockRouter

	static let shared = MockClient()

	private(set) lazy var session: Session = Session()
}

extension MockClient {
	typealias Handler<T> = (Result<T, Error>) -> Void

	func empty(then handler: @escaping Handler<Void>) {
		requestVoid(.user, then: handler)
	}

	func data(then handler: @escaping Handler<Data>) {
		requestData(.user, then: handler)
	}

	func string(then handler: @escaping Handler<String>) {
		requestString(.user, then: handler)
	}

	func json(then handler: @escaping Handler<Any>) {
		requestJSON(.user, then: handler)
	}

	func decodable(then handler: @escaping Handler<MockUser>) {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		requestDecodable(.user, decoder: decoder, then: handler)
	}

	func insert(database: DB, then handler: @escaping Handler<MockProfile>) {
		requestInsert(.user, db: database, then: handler)
	}
}

@available(iOS 13, *)
extension MockClient {
	func empty() async -> Result<Void, Error> {
		await requestVoid(.user)
	}

	func data() async -> Result<Data, Error> {
		await requestData(.user)
	}

	func string() async -> Result<String, Error> {
		await requestString(.user)
	}

	func json() async -> Result<Any, Error> {
		await requestJSON(.user)
	}

	func decodable() async -> Result<MockUser, Error> {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		return await requestDecodable(.user, decoder: decoder)
	}

	func insert(database: DB) async -> Result<MockProfile, Error> {
		await requestInsert(.user, db: database)
	}

	func cancel(automaticallyCancelling: Bool) async -> Result<Void, Error> {
		await requestVoid(.user, automaticallyCancelling: automaticallyCancelling)
	}
}
