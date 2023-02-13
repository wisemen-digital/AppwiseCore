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
		let randomString = UUID().uuidString
		let randomData = Data(randomString.utf8)

		stub(condition: routerCondition) { _ in
			HTTPStubsResponse(data: randomData, statusCode: 200, headers: nil).then {
				$0.requestTime = delay
			}
		}

		return randomData
	}

	static func registerUser() {
		stub(condition: routerCondition) { _ in
			HTTPStubsResponse(
				fileAtPath: OHPathForFileInBundle("user.json", testBundle).require(),
				statusCode: 200,
				headers: ["Content-Type": "application/json"]
			)
		}
	}
}

extension StubHelper {
	static func routerCondition(request: URLRequest) -> Bool {
		request.url.map { $0.absoluteString.contains(MockRouter.baseURLString) } ?? false
	}

	static var testBundle: Bundle {
		let bundle = Bundle(for: BundleToken.self)

		if let url = bundle.url(forResource: "Tests", withExtension: "bundle") {
			return Bundle(url: url).require()
		} else {
			fatalError("Test bundle not found")
		}
	}
}

private class BundleToken { }
