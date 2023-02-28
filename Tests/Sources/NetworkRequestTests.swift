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
			XCTAssertTrue(result.isSuccess)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testData() {
		let randomData = StubHelper.registerRandomData()
		let expectation = XCTestExpectation()

		client.data { result in
			XCTAssertTrue(result.isSuccess)
			XCTAssertEqual(randomData, result.value)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testJSON() throws {
		let data = try StubHelper.register(encodable: MockUser.default)
		let json = try JSONSerialization.jsonObject(with: data)
		let expectation = XCTestExpectation()

		client.json { result in
			XCTAssertTrue(result.isSuccess)
			if let value = result.value {
				XCTAssertTrue(areEqual(first: value, second: json))
			}
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testDecodable() throws {
		let user = MockUser.default
		try StubHelper.register(encodable: MockUser.default)
		let expectation = XCTestExpectation()

		client.decodable { result in
			XCTAssertTrue(result.isSuccess)
			XCTAssertEqual(user, result.value)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testString() {
		let data = StubHelper.registerRandomData()
		let string = String(data: data, encoding: .utf8)
		let expectation = XCTestExpectation()

		client.string { result in
			XCTAssertTrue(result.isSuccess)
			XCTAssertEqual(result.value, string)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}

	func testInsert() async throws {
		let user = MockUser.default
		try StubHelper.register(encodable: user)
		let database = DataBaseHelper.setupDefault()
		let expectation = XCTestExpectation()

		client.insert(database: database) { result in
			XCTAssertTrue(result.isSuccess)
			XCTAssertEqual(Int64(user.id), result.value?.id.rawValue)
			XCTAssertEqual(user.email, result.value?.email)
			XCTAssertEqual(user.firstName, result.value?.firstName)
			XCTAssertEqual(user.lastName, result.value?.lastName)
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 1)
	}
}
