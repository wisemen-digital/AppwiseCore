//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
@testable import AppwiseCore
import OHHTTPStubs
import XCTest

@available(iOS 13, *)
final class AsyncNetworkRequestTests: XCTestCase {
	private let client = MockClient.shared

	override func tearDown() {
		super.tearDown()

		HTTPStubs.removeAllStubs()
	}
}

// MARK: - General

@available(iOS 13, *)
extension AsyncNetworkRequestTests {
	func testVoid() async {
		StubHelper.registerEmpty()
		let result = await client.empty()

		XCTAssertTrue(result.isSuccess)
	}

	func testData() async {
		let data = StubHelper.registerRandomData()
		let result = await client.data()

		XCTAssertTrue(result.isSuccess)
		XCTAssertEqual(result.value, data)
	}

	func testJSON() async throws {
		let user = MockUser.default
		let data = try StubHelper.register(encodable: user)
		let result = await client.json()
		let json = try JSONSerialization.jsonObject(with: data)

		XCTAssertTrue(result.isSuccess)
		if let value = result.value {
			XCTAssertTrue(areEqual(first: value, second: json))
		}
	}

	func testDecodable() async throws {
		let user = MockUser.default
		try StubHelper.register(encodable: user)
		let result = await client.decodable()

		XCTAssertTrue(result.isSuccess)
		XCTAssertEqual(user, result.value)
	}

	func testString() async {
		let data = StubHelper.registerRandomData()
		let string = String(data: data, encoding: .utf8)
		let result = await client.string()

		XCTAssertTrue(result.isSuccess)
		XCTAssertEqual(result.value, string)
	}

	func testInsert() async throws {
		let user = MockUser.default
		try StubHelper.register(encodable: user)
		let database = DataBaseHelper.setupDefault()
		let result = await client.insert(database: database)

		XCTAssertTrue(result.isSuccess)
		XCTAssertEqual(Int64(user.id), result.value?.id.rawValue)
		XCTAssertEqual(user.email, result.value?.email)
		XCTAssertEqual(user.firstName, result.value?.firstName)
		XCTAssertEqual(user.lastName, result.value?.lastName)
	}
}

// MARK: - Cancellation

@available(iOS 13, *)
extension AsyncNetworkRequestTests {
	func testRequestCancel() async throws {
		StubHelper.registerRandomData(delay: 0.02) // 20 milliseconds

		let task = Task { await client.cancel(automaticallyCancelling: true) }
		try await Task.sleep(nanoseconds: 10_000_000) // 10 milliseconds
		task.cancel()
		let result = await task.value

		XCTAssertTrue(result.isFailure)
		if case .explicitlyCancelled = result.error as? AFError {
			XCTAssertTrue(true)
		} else {
			XCTAssertTrue(false)
		}
	}

	func testRequestCancelIgnored() async throws {
		StubHelper.registerRandomData(delay: 0.02) // 20 milliseconds

		let task = Task { await client.cancel(automaticallyCancelling: false) }
		try await Task.sleep(nanoseconds: 10_000_000) // 10 milliseconds
		task.cancel()
		let result = await task.value

		XCTAssertTrue(result.isSuccess)
		XCTAssertNil(result.error)
	}
}
