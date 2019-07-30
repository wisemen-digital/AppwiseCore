//
//  Operator.swift
//  Alamofire+CoreData
//
//  Created by Manu on 15/2/16.
//  Copyright © 2016 manuege. All rights reserved.
//

import Foundation

infix operator <-

public extension Optional where Wrapped == MapValue {
	// MARK: Insertable Operator

	static func <- <T: Insertable>(left: inout T, right: MapValue?) throws {
		guard let mapValue = right else { return }

		let value: T? = try mapValue.serialize()
		if let value = value {
			left = value
		} else {
			throw InsertError.invalidValue(key: mapValue.keyPath, type: T.self)
		}
	}

	static func <- <T: Insertable>(left: inout T?, right: MapValue?) {
		if let mapValue = right,
			let value = try? mapValue.serialize() as T? {
			left = value
		}
	}

	// MARK: Generic operator

	static func <- <T>(left: inout T, right: MapValue?) throws {
		try left <- (right, { $0 })
	}

	static func <- <T: ExpressibleByNilLiteral> (left: inout T, right: MapValue?) {
		left <- (right, { $0 })
	}
}

// MARK: Generic operator with converter

// swiftlint:disable:next static_operator
public func <- <T, R>(left: inout T, right: (mapValue: MapValue?, transformer: (R) -> T)) throws {
    guard let mapValue = right.mapValue else {
        return
    }

    guard let originalValue = mapValue.originalValue as? R else {
    	throw InsertError.invalidValue(key: mapValue.keyPath, type: R.self)
    }
    let transformedValue = right.transformer(originalValue)
    left = transformedValue as T
}

// swiftlint:disable:next static_operator
public func <- <T: ExpressibleByNilLiteral, R>(left: inout T, right: (mapValue: MapValue?, transformer: (R) -> T)) {
    guard let mapValue = right.mapValue else {
        return
    }

    guard let originalValue = mapValue.originalValue else {
        left = nil
        return
    }

    let transformedValue = right.transformer((originalValue as? R).require(hint: "Value is not of type \(R.self)"))
    left = transformedValue as T
}
