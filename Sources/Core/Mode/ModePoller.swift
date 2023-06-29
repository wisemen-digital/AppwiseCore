//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Alamofire

public protocol ModePollerExecutor {
	func poll() async -> ModeResult
}

public struct ClientModePollerExecutor<C: Client>: ModePollerExecutor {
	private let client: C
	private let route: C.RouterType

	private let extractor: ModeExtractor

	public init(client: C, route: C.RouterType, extractor: ModeExtractor) {
		self.client = client
		self.route = route
		self.extractor = extractor
	}

	public func poll() async -> ModeResult {
		let task = client.request(route).serializingResponse(using: DataResponseSerializer())
		return extractor.extract(response: await task.response)
	}
}

public final actor ModePoller {
	private let manager: ModeManager
	private let executor: ModePollerExecutor
	private let updateInterval: TimeInterval

	private var task: Task<Void, Never>?

	public init(manager: ModeManager, executor: ModePollerExecutor, updateInterval: TimeInterval = 60) {
		self.manager = manager
		self.executor = executor
		self.updateInterval = updateInterval
	}

	public func start() {
		if task != nil {
			return
		} else {
			task = Task {
				await check()
			}
		}
	}

	public func stop() {
		task?.cancel()
		task = nil
	}

	private func check() async {
		repeat {
			let result = await executor.poll()

			switch result {
			case .state(let mode): await manager.update(mode: mode)
			case .empty: await manager.update(mode: nil)
			case .unknown: break
			}

			let mulitplier: TimeInterval = 1_000_000_000
			let nanoSeconds = updateInterval * mulitplier
			try? await Task.sleep(nanoseconds: UInt64(nanoSeconds))
		} while !Task.isCancelled
	}
}
