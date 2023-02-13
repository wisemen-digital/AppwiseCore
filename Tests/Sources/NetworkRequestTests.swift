//
// AppwiseCore
// Copyright © 2022 Appwise
//

import AppwiseCore
import OHHTTPStubs
import XCTest

final class NetworkRequestsTests: XCTestCase {
	private let client = MockClient.shared

	override func tearDown() {
		super.tearDown()

		HTTPStubs.removeAllStubs()
	}
}

// MARK: - General

extension NetworkRequestsTests {
	func testVoid() {
		StubHelper.registerEmpty()
		let expectation = XCTestExpectation()

		client.empty { result in
			XCTAssert(result.isSuccess)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testData() {
		let randomData = StubHelper.registerRandomData()
		let expectation = XCTestExpectation()

		client.data { result in
			XCTAssert(result.isSuccess)
			XCTAssert(randomData == result.value)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testJSON() {
		StubHelper.registerUser()
		let expectation = XCTestExpectation()

		client.json { result in
			XCTAssert(result.isSuccess)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testDecodable() {
		StubHelper.registerUser()
		let user = MockUser.example()
		let expectation = XCTestExpectation()

		client.decodable { result in
			XCTAssert(result.isSuccess)
			XCTAssert(user == result.value)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testString() {
		StubHelper.registerUser()
		let expectation = XCTestExpectation()

		client.string { result in
			XCTAssert(result.isSuccess)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}
}
