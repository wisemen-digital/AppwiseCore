//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Alamofire

/// Structured error information, including sub-errors if available.
public struct ClientStructuredError: Decodable, LocalizedError {
	public let message: String
	// swiftlint:disable:next discouraged_optional_collection
	public let errors: [String: [String]]?

	public var errorDescription: String? {
		let subItems: [String] = errors?
			.sorted { $0.key < $1.key }
			.flatMap(\.value)
			.map { " • \($0)" } ?? []

		return ([message] + subItems).joined(separator: "\n")
	}
}

/// Potential extra errors returned by `Client.extract(from:error)`
public enum ClientError: Error, LocalizedError {
	/// Multiple structured errors in response
	case errors([ClientStructuredError], underlyingError: Error)
	/// Message from response
	case message(String, underlyingError: Error)
	/// In case of HTTP Status 401 or 403
	case unauthorized(underlyingError: Error)
	/// Client detected a certain mode
	case mode(Mode, underlyingError: Error)

	public var errorDescription: String? {
		switch self {
		case .errors(let errors, _):
			return errors
				.compactMap(\.errorDescription)
				.joined(separator: "\n")
		case .message(let message, _):
			return message
		case .unauthorized:
			return L10n.Client.Error.unauthorized
		case .mode(_, let error):
			return error.localizedDescription
		}
	}

	/// The underlying error as reported by serializers, Alamofire, ...
	public var underlyingError: Error {
		switch self {
		case .errors(_, let error), .message(_, let error), .unauthorized(let error), .mode(_, let error):
			return error
		}
	}
}

// For internal use only
struct DeprecatedError: Error { }
