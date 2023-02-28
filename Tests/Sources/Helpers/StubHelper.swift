//
// AppwiseCore
// Copyright © 2022 Appwise
//

import AppwiseCore
import Foundation
import OHHTTPStubs

enum StubHelper {
	static func registerEmpty() {
		stub(condition: routerCondition) { _ in
			HTTPStubsResponse(data: Data(), statusCode: 200, headers: nil)
		}
	}

	@discardableResult
	static func registerRandomData(delay: TimeInterval = 0) -> Data {
		let string = UUID().uuidString
		let data = Data(string.utf8)

		register(data: data, delay: delay)

		return data
	}

	static func register(data: Data, delay: TimeInterval = 0) {
		stub(condition: routerCondition) { _ in
			HTTPStubsResponse(data: data, statusCode: 200, headers: nil).then {
				$0.requestTime = delay
			}
		}
	}

	@discardableResult
	static func register(encodable: Encodable, delay: TimeInterval = 0) throws -> Data {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase

		let data = try encoder.encode(encodable)

		stub(condition: routerCondition) { _ in
			HTTPStubsResponse(
				data: data,
				statusCode: 200,
				headers: ["Content-Type": "application/json"]
			).then {
				$0.requestTime = delay
			}
		}

		return data
	}
}

extension StubHelper {
	static func routerCondition(request: URLRequest) -> Bool {
		request.url.map { $0.absoluteString.contains(MockRouter.baseURLString) } ?? false
	}
} 
