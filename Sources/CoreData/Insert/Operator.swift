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

	static func <- <T: Insertable>(left: inout T, right: MapValue?) {
		if let mapValue = right {
			let value: T? = mapValue.serialize()
			left = value.require(hint: "Unable to serialze value")
		}
	}

	static func <- <T: Insertable>(left: inout T?, right: MapValue?) {
		if let mapValue = right {
			let value: T? = mapValue.serialize()
			left = value
		}
	}

	// MARK: Generic operator

	static func <- <T>(left: inout T, right: MapValue?) {
		left <- (right, { $0 })
	}

	static func <- <T: ExpressibleByNilLiteral> (left: inout T, right: MapValue?) {
		left <- (right, { $0 })
	}
}

// MARK: Generic operator with converter

// swiftlint:disable:next static_operator
public func <- <T, R>(left: inout T, right: (mapValue: MapValue?, transformer: (R) -> T)) {
    guard let mapValue = right.mapValue else {
        return
    }

    let originalValue = (mapValue.originalValue as? R).require(hint: "Value is not of type \(R.self)")
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
