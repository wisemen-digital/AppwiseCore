//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Alamofire

public struct ModeEventMonitor {
	private let manager: ModeManager
	private let extractor: ModeExtractor

	public init(manager: ModeManager, extractor: ModeExtractor) {
		self.manager = manager
		self.extractor = extractor
	}

	private func handle(result: ModeResult) {
		Task {
			switch result {
			case .state(let mode): await manager.update(mode: mode)
			case .empty: await manager.update(mode: nil)
			case .unknown: break
			}
		}
	}
}

extension ModeEventMonitor: EventMonitor {
	public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
		handle(result: extractor.extract(response: response))
	}

	public func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
		handle(result: extractor.extract(response: response))
	}
}
