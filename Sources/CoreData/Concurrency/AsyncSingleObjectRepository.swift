//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Foundation

@available(iOS 13.0, *)
public protocol AsyncSingleObjectRepository: SingleObjectRepository {
	func refresh() async throws -> ObjectType
}

@available(iOS 13.0, *)
public extension AsyncSingleObjectRepository {
	func refresh() async throws -> ObjectType {
		throw Cancelled()
	}

	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void) {
		Task { @MainActor in
			let result = await Result { try await refresh() }
			handler(result)
		}
	}
}
