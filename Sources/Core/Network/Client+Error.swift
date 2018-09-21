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
	case message(String)
	/// In case of HTTP Status 401 or 403
	case unauthorized
	
	case notfound

	public var errorDescription: String? {
		switch self {
		case .message(let message):
			return message
		case .notFound:
			return L10n.Client.Error.notfound
		case .unauthorized:
			return L10n.Client.Error.unauthorized
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
			return ClientError.unauthorized
		}
		
		if let status = response.response?.statusCode, status == 404 {
			return ClientError.notfound
		}

		guard let data = response.data else { return error }
		let json = try? JSONSerialization.jsonObject(with: data, options: [])

		if let json = json as? [[String: String]],
			let message = json.first?[Keys.message] {
			return ClientError.message(message)
		} else if let json = json as? [String: String],
			let message = json[Keys.message] {
			return ClientError.message(message)
		} else if let message = String(data: data, encoding: .utf8) {
			return ClientError.message(message)
		} else {
			return error
		}
	}
}
