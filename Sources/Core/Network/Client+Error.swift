//
//  Client+Error.swift
//  AppwiseCore
//
//  Created by David Jennes on 24/07/2018.
//

import Alamofire

/// Potential extra errors returned by `Client.extract(from:error)`
public enum ClientError: Error, LocalizedError {
	/// Message from response
	case message(String, underlyingError: Error)
	/// In case of HTTP Status 401 or 403
	case unauthorized(underlyingError: Error)

	public var errorDescription: String? {
		switch self {
		case .message(let message, _):
			return message
		case .unauthorized:
			return L10n.Client.Error.unauthorized
		}
	}

	/// The underlying error as reported by serializers, Alamofire, ...
	public var underlyingError: Error {
		switch self {
		case .message(_, let error), .unauthorized(let error):
			return error
		}
	}
}

private enum Keys {
	static let message = "message"
}

public extension Client {
	/// Extract a readable error from the response in case of an error. This default implementation will:
	/// - Check if authorized
	/// - Consider the response as an array of objects, and get the first object's `message`
	/// - Consider the response as an object, and get the object's `message`
	/// - Consider the response as a string, and use that as error message
	///
	/// - parameter response: The data response
	/// - parameter error: The existing error
	///
	/// - returns: An error with the message from the response (see `ClientError`), or the existing error
	static func extract<T>(from response: DataResponse<T>, error: Error) -> Error {
		if let status = response.response?.statusCode, status == 401 || status == 403 {
			return ClientError.unauthorized(underlyingError: error)
		}

		guard let data = response.data else { return error }
		let json = try? JSONSerialization.jsonObject(with: data, options: [])

		if let json = json as? [[String: Any]],
			let message = json.first?[Keys.message] as? String {
			return ClientError.message(message, underlyingError: error)
		} else if let json = json as? [String: Any],
			let message = json[Keys.message] as? String {
			return ClientError.message(message, underlyingError: error)
		} else if let message = String(data: data, encoding: .utf8),
			!message.lowercased().contains("<html"),
			!message.isEmpty {
			return ClientError.message(message, underlyingError: error)
		} else {
			return error
		}
	}
}
