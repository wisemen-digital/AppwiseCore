//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Foundation

@available(iOS 13.0, *)
public protocol AsyncSingleObjectRepository: SingleObjectRepository {
	func refresh() async throws -> ObjectType
}

@available(iOS 13.0, *)
public extension AsyncSingleObjectRepository {
	func refresh() async throws -> ObjectType {
		assertionFailure("Forgot to implement refresh handler of repository \(Self.self).")
		throw UnimplementedMethod()
	}

	func refresh(then handler: @escaping (Result<ObjectType, Error>) -> Void) {
		Task { @MainActor in
			let result = await Result { try await refresh() }
			handler(result)
		}
	}
}
