//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Alamofire
import AppwiseCore
import OHHTTPStubs
import XCTest

@available(iOS 13, *)
final class AsyncNetworkRequestsTests: XCTestCase {
	private let client = MockClient.shared

	override func tearDown() {
		super.tearDown()

		HTTPStubs.removeAllStubs()
	}
}

// MARK: - General

@available(iOS 13, *)
extension AsyncNetworkRequestsTests {
	func testVoid() async {
		StubHelper.registerEmpty()
		let result = await client.empty()

		XCTAssert(result.isSuccess)
	}

	func testData() async {
		let randomData = StubHelper.registerRandomData()
		let result = await client.data()

		XCTAssert(result.isSuccess)
		if case .success(let data) = result {
			XCTAssert(randomData == data)
		}
	}

	func testJSON() async {
		StubHelper.registerUser()
		let result = await client.json()

		XCTAssert(result.isSuccess)
	}

	func testDecodable() async {
		StubHelper.registerUser()
		let result = await client.decodable()
		let user = MockUser.example()

		XCTAssert(result.isSuccess)
		XCTAssert(user == result.value)
	}

	func testString() async {
		StubHelper.registerUser()

		let result = await client.string()
		XCTAssertTrue(result.isSuccess)
	}
}

// MARK: - Cancellation

@available(iOS 13, *)
extension AsyncNetworkRequestsTests {
	func testRequestCancel() async throws {
		StubHelper.registerRandomData(delay: 0.02) // 20 milliseconds

		let task = Task { await client.cancel(automaticallyCancelling: true) }
		try await Task.sleep(nanoseconds: 10_000_000) // 10 milliseconds
		task.cancel()
		let result = await task.value

		XCTAssert(result.isFailure)
		if case .explicitlyCancelled = result.error as? AFError {
			XCTAssert(true)
		} else {
			XCTAssert(false)
		}
	}

	func testRequestCancelIgnored() async throws {
		StubHelper.registerRandomData(delay: 0.02) // 20 milliseconds

		let task = Task { await client.cancel(automaticallyCancelling: false) }
		try await Task.sleep(nanoseconds: 10_000_000) // 10 milliseconds
		task.cancel()
		let result = await task.value

		XCTAssert(result.isSuccess)
	}
}
