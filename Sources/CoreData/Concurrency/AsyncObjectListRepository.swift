//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Foundation

@available(iOS 13.0, *)
public protocol AsyncObjectListRepository: ObjectListRepository {
	func refresh() async -> Result<[ObjectType], Error>
}

@available(iOS 13.0, *)
public extension AsyncObjectListRepository {
	func refresh() async -> Result<[ObjectType], Error> {
		.cancelled
	}

	func refresh(then handler: @escaping (Result<[ObjectType], Error>) -> Void) {
		Task { @MainActor in
			let result = await refresh()
			handler(result)
		}
	}
}
