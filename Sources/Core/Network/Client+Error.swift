//
//  Client+Error.swift
//  AppwiseCore
//
//  Created by David Jennes on 24/07/2018.
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
			.flatMap { $0.value }
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

	public var errorDescription: String? {
		switch self {
		case .errors(let errors, _):
			return errors
				.compactMap { $0.errorDescription }
				.joined(separator: "\n")
		case .message(let message, _):
			return message
		case .unauthorized:
			return L10n.Client.Error.unauthorized
		}
	}

	/// The underlying error as reported by serializers, Alamofire, ...
	public var underlyingError: Error {
		switch self {
		case .errors(_, let error), .message(_, let error), .unauthorized(let error):
			return error
		}
	}
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
		// unauthorized status code --> unauthorized
		if let status = response.response?.statusCode, status == 401 || status == 403 {
			return ClientError.unauthorized(underlyingError: error)
		} else if let data = response.data {
			// try to parse structured error or simple message
			if let items = try? JSONDecoder().decode([ClientStructuredError].self, from: data) {
				return ClientError.errors(items, underlyingError: error)
			} else if let item = try? JSONDecoder().decode(ClientStructuredError.self, from: data) {
				return ClientError.errors([item], underlyingError: error)
			} else if let message = String(data: data, encoding: .utf8),
				!message.lowercased().contains("<html"),
				!message.isEmpty {
				return ClientError.message(message, underlyingError: error)
			}
		}

		return error
	}
}
