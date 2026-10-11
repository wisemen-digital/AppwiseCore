//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import Foundation

public protocol AsyncObjectListRepository: ObjectListRepository {
	func refresh() async throws -> [ObjectType]
}

public extension AsyncObjectListRepository {
	func refresh() throws -> [ObjectType] {
		assertionFailure("Forgot to implement refresh handler of repository \(Self.self).")
		throw UnimplementedMethod()
	}

	func refresh(then handler: @escaping (Result<[ObjectType], Error>) -> Void) {
		Task { @MainActor in
			let result = await Result { try await refresh() }
			handler(result)
		}
	}
}
