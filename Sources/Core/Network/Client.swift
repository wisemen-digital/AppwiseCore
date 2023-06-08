//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Alamofire

/// Representation of network client, works in conjunction with the `Router` protocol. The
/// router will provide the requests, the client (this) will peform the actual calls and
/// process the responses.
public protocol Client {
	/// The router type for this client
	associatedtype RouterType: Router

	/// A client is a singleton
	static var shared: Self { get }

	/// The Alamofire session for this client
	var session: Session { get }

	/// Protocol used to check if a response matches maintenance mode
	static var maintenanceChecker: MaintenanceModeResponseChecker.Type? { get }

	/// Extract a readable error from the response in case of an error.
	///
	/// - parameter response: The data response
	/// - parameter error: The existing error
	///
	/// - returns: An error with the message from the response (see `ClientError`), or the existing error
	static func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error
}

public extension Client {
	/// Shortcut method for creating a request
	///
	/// - parameter request: The router request type
	///
	/// - returns: The data request object
	func request(_ request: RouterType) -> DataRequest {
		request.makeDataRequest(session: session)
			.validate()
	}

	@available(*, unavailable, renamed: "request(_:)")
	func buildRequest(_ request: RouterType, completion: @escaping (_ result: Result<DataRequest, Error>) -> Void) {
		fatalError("unavailable")
	}
}
