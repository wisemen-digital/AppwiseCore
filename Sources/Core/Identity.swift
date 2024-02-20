//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Foundation

// Credit to John Sundell for the original implementation:
// https://github.com/JohnSundell/Identity
// Last sync on 19 November 2019

/// Protocol used to mark a given type as being identifiable, meaning
/// that it has a type-safe identifier, backed by a raw value, which
/// defaults to String.
public protocol _TaggedIdentifiable {
	// swiftlint:disable:previous type_name

	// Note: once we remove `OptionalIdentifiable`, unify this protocol with `TaggedIdentifiable` below.

	/// The backing raw type of this type's identifier.
	associatedtype RawIdentifier: Hashable

	/// The object type (hack needed to support subclasses)
	associatedtype IdentifierObjectType: _TaggedIdentifiable = Self

	/// Shorthand type alias for this type's identifier.
	typealias TaggedID = Identifier<IdentifierObjectType>

	// swiftlint:disable type_name
	/// Shorthand type alias for this type's identifier.
	///
	/// - Warning: Prefer `TaggedID` to avoid ambiguity errors.
	typealias ID = TaggedID
	// swiftlint:enable type_name
}

/// Protocol used to mark a given type as being identifiable, meaning
/// that it has a type-safe identifier, backed by a raw value, which
/// defaults to String.
public protocol TaggedIdentifiable<RawIdentifier>: _TaggedIdentifiable, Swift.Identifiable {
	// swiftlint:disable identifier_name
	/// The ID of this instance.
	var id: TaggedID { get }
	// swiftlint:enable identifier_name
}

/// A type-safe identifier for a given `Value`, backed by a raw value.
/// When backed by a `Codable` type, `Identifier` also becomes codable,
/// and will be encoded into a single value according to its raw value.
public struct Identifier<Value: _TaggedIdentifiable>: RawRepresentable {
	/// The raw value that is backing this identifier.
	public let rawValue: Value.RawIdentifier

	/// Initialize an instance with a raw value.
	public init?(rawValue: Value.RawIdentifier) {
		self.rawValue = rawValue
	}

	/// Initialize an instance with a raw value.
	public init(_ value: Value.RawIdentifier) {
		rawValue = value
	}
}

// MARK: - Integer literal support

extension Identifier: ExpressibleByIntegerLiteral where Value.RawIdentifier: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Value.RawIdentifier.IntegerLiteralType) {
		rawValue = .init(integerLiteral: value)
	}
}

// MARK: - String literal support

extension Identifier: ExpressibleByUnicodeScalarLiteral where Value.RawIdentifier: ExpressibleByUnicodeScalarLiteral {
	public init(unicodeScalarLiteral value: Value.RawIdentifier.UnicodeScalarLiteralType) {
		rawValue = .init(unicodeScalarLiteral: value)
	}
}

extension Identifier: ExpressibleByExtendedGraphemeClusterLiteral where Value.RawIdentifier: ExpressibleByExtendedGraphemeClusterLiteral {
	public init(extendedGraphemeClusterLiteral value: Value.RawIdentifier.ExtendedGraphemeClusterLiteralType) {
		rawValue = .init(extendedGraphemeClusterLiteral: value)
	}
}

extension Identifier: ExpressibleByStringLiteral where Value.RawIdentifier: ExpressibleByStringLiteral {
	public init(stringLiteral value: Value.RawIdentifier.StringLiteralType) {
		rawValue = .init(stringLiteral: value)
	}
}

// MARK: - Conversion to String

extension Identifier: CustomStringConvertible {
	public var description: String {
		String(describing: rawValue)
	}
}

extension Identifier: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Identifier<\(Value.self)>(\(rawValue))"
	}
}

// MARK: - Hashable & Comparable

extension Identifier: Equatable where Value.RawIdentifier: Equatable {}

extension Identifier: Hashable where Value.RawIdentifier: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(String(describing: Value.self))
		hasher.combine(rawValue)
	}
}

extension Identifier: Comparable where Value.RawIdentifier: Comparable {
	public static func < (lhs: Identifier<Value>, rhs: Identifier<Value>) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}

// MARK: - Codable support

extension Identifier: Codable where Value.RawIdentifier: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		rawValue = try container.decode(Value.RawIdentifier.self)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "TaggedIdentifiable")
public typealias Identifiable = TaggedIdentifiable

@available(*, deprecated, message: "Will be removed in next major version")
public protocol OptionalIdentifiable: _TaggedIdentifiable {
	// swiftlint:disable identifier_name
	var id: TaggedID? { get }
	// swiftlint:enable identifier_name
}
