//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Alamofire

public protocol ClientErrorExtractor {
	func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error?
}

public struct IgnoredErrorExtractor: ClientErrorExtractor {
	public func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error? {
		if error.isExplicitlyCancelledError {
			return error
		} else {
			return nil
		}
	}
}

public struct AuthenticationErrorExtractor: ClientErrorExtractor {
	public init() { }

	public func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error? {
		if let status = response.response?.statusCode, status == 401 || status == 403 { // unauthorized status code --> unauthorized
			return ClientError.unauthorized(underlyingError: error)
		} else {
			return nil
		}
	}
}

public struct StructuredErrorExtractor: ClientErrorExtractor {
	public init() { }

	public func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error? {
		guard let data = response.data else { return nil }

		if let items = try? JSONDecoder().decode([ClientStructuredError].self, from: data) {
			return ClientError.errors(items, underlyingError: error)
		} else if let item = try? JSONDecoder().decode(ClientStructuredError.self, from: data) {
			return ClientError.errors([item], underlyingError: error)
		} else {
			return nil
		}
	}
}

public struct MessageErrorExtractor: ClientErrorExtractor {
	public init() { }

	public func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error? {
		guard let data = response.data,
			  let message = String(data: data, encoding: .utf8),
			  !message.lowercased().contains("<html"),
			  !message.isEmpty else { return nil }

		return ClientError.message(message, underlyingError: error)
	}
}

public struct ModeErrorExtractor: ClientErrorExtractor {
	private let extractor: ModeExtractor

	public init(extractor: ModeExtractor) {
		self.extractor = extractor
	}

	public func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error? {
		switch extractor.extract(response: response) {
		case .state(let mode): return ClientError.mode(mode, underlyingError: error)
		default: return nil
		}
	}
}

public struct CompoundErrorExtractor: ClientErrorExtractor {
	private let extractors: [ClientErrorExtractor]

	public init(extractors: [ClientErrorExtractor]) {
		self.extractors = extractors
	}

	public func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error? {
		for extractor in extractors {
			if let error = extractor.extract(from: response, error: error) {
				return error
			}
		}

		return nil
	}
}

public extension Client {
	var errorExtractor: ClientErrorExtractor {
		CompoundErrorExtractor(extractors: [
			IgnoredErrorExtractor(),
			AuthenticationErrorExtractor(),
			ModeErrorExtractor(extractor: MaintenanceModeExtractor.default()),
			StructuredErrorExtractor(),
			MessageErrorExtractor()
		])
	}

	// TODO: find a way to migrate without breaking changes
	static func extract<T>(from response: DataResponse<T, AFError>, error: AFError) -> Error {
		DeprecatedError()
	}
}
