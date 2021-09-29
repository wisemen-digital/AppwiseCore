//
// AppwiseCore
// Copyright © 2021 Appwise
//

import Foundation

/// Useful for when you need to encode "something" (but don't have a concrete type)
public struct AnyEncodable: Encodable {
	let wrapped: Encodable

	public init(_ wrapped: Encodable) {
		self.wrapped = wrapped
	}

	public func encode(to encoder: Encoder) throws {
		try wrapped.encode(to: encoder)
	}
}
