//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Foundation

@available(iOS 13, *)
public extension Result where Failure == Error {
	init(catching body: () async throws -> Success) async {
		do {
			self = try await .success(body())
		} catch {
			self = .failure(error)
		}
	}
}
