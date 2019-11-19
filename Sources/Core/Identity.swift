//
//  Identity.swift
//  AppwiseCore
//
//  Created by David Jennes on 20/02/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

// Credit to John Sundell for the original implementation:
// https://github.com/JohnSundell/Identity
// Last sync on 19 November 2019

/// Protocol used to mark a given type as being identifiable, meaning
/// that it has a type-safe identifier, backed by a raw value, which
/// defaults to String.
public protocol _Identifiable {
	/// The backing raw type of this type's identifier.
	associatedtype RawIdentifier

	/// The object type (hack needed to support subclasses)
	associatedtype IdentifierObjectType: _Identifiable = Self

	// swiftlint:disable type_name
	/// Shorthand type alias for this type's identifier.
	typealias ID = Identifier<IdentifierObjectType>
	// swiftlint:enable type_name
}

/// Protocol used to mark a given type as being identifiable, meaning
/// that it has a type-safe identifier, backed by a raw value, which
/// defaults to String.
public protocol Identifiable: _Identifiable {
	// swiftlint:disable identifier_name
	/// The ID of this instance.
	var id: ID { get }
	// swiftlint:enable identifier_name
}

/// Protocol used to mark a given type as being identifiable, meaning
/// that it has a type-safe identifier, backed by a raw value, which
/// defaults to String.
public protocol OptionalIdentifiable: _Identifiable {
	// swiftlint:disable identifier_name
	/// The ID of this instance.
	var id: ID? { get }
	// swiftlint:enable identifier_name
}

/// A type-safe identifier for a given `Value`, backed by a raw value.
/// When backed by a `Codable` type, `Identifier` also becomes codable,
/// and will be encoded into a single value according to its raw value.
public struct Identifier<Value: _Identifiable>: RawRepresentable {
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
		return String(describing: rawValue)
	}
}

extension Identifier: CustomDebugStringConvertible {
	public var debugDescription: String {
		return "Identifier<\(Value.self)>(\(rawValue))"
	}
}

// MARK: - Hashable & Comparable

extension Identifier: Equatable where Value.RawIdentifier: Equatable {}

extension Identifier: Hashable where Value.RawIdentifier: Hashable {}

extension Identifier: Comparable where Value.RawIdentifier: Comparable {
	public static func < (lhs: Identifier<Value>, rhs: Identifier<Value>) -> Bool {
		return lhs.rawValue < rhs.rawValue
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
