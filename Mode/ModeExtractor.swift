//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Alamofire

public enum ModeResult {
	case state(mode: Mode)
	case empty
	case unknown

	var mode: Mode? {
		switch self {
		case .state(let mode): return mode
		default: return nil
		}
	}
}

public protocol ModeExtractor {
	func extract<T>(response: DataResponse<T, AFError>) -> ModeResult
}

public struct MaintenanceModeExtractor: ModeExtractor {
	private let decoder: JSONDecoder

	public static func `default`() -> MaintenanceModeExtractor {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.keyDecodingStrategy = .convertFromSnakeCase

		return .init(decoder: decoder)
	}

	public init(decoder: JSONDecoder) {
		self.decoder = decoder
	}

	public func extract<T>(response: DataResponse<T, AFError>) -> ModeResult {
		let statusCode = response.response?.statusCode

		if response.result.isSuccess || statusCode == nil {
			return .empty
		} else if let statusCode = statusCode, 502...503 ~= statusCode {
			let metaData: MaintenanceMetaData? = response.data.flatMap { decode(data: $0) }
			let maintenance = Mode(identifier: ModeIdentifier.maintenance.rawValue, metaData: metaData)
			return .state(mode: maintenance)
		} else {
			return .unknown
		}
	}

	private func decode<T: Decodable>(data: Data) -> T? {
		do {
			return try decoder.decode(T.self, from: data)
		} catch {
			return nil
		}
	}
}

public struct CompoundModeExtractor: ModeExtractor {
	private let extractors: [ModeExtractor]

	public init(extractors: [ModeExtractor]) {
		self.extractors = extractors
	}

	public func extract<T>(response: DataResponse<T, AFError>) -> ModeResult {
		var hasEmpty = false

		for extractor in extractors {
			let result = extractor.extract(response: response)

			switch result {
			case .state(let mode): return .state(mode: mode)
			case .empty: hasEmpty = true
			case .unknown: continue
			}
		}

		return hasEmpty ? .empty : .unknown
	}
}
