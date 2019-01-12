//
//  ViewModel.swift
//  AppwiseCore
//
//  Created by David Jennes on 29/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation
import Then

/// A `ViewModel` is a light layer between the data layer (models) and the view layer (View and ViewController).
/// If for example certain properties need formatting before display, then that formatting code should exist in
/// the view model.
public protocol ViewModel: Then {
	/// The data model type
	associatedtype Model

	/// The data instance
	var data: Model { get }

	/// Mandatory initializer
	init(_ data: Model)
}

public extension ViewModel {
	/// Initializer for handling optionals. If the data instance is nil, the view model will also be nil.
	///
	/// - parameter data: The data instance (can be nil)
	init?(_ data: Model?) {
		if let data = data {
			self.init(data)
		} else {
			return nil
		}
	}
}

public extension ViewModel where Model: NSObject {
	/// Check if the data instance has a non-empty value for a specific key
	///
	/// - parameter key: A valid key path for the data type
	///
	/// - returns: True if the value is non-empty
	func has(_ key: PartialKeyPath<Model>) -> Bool {
		switch data[keyPath: key] {
		case let value as String:
			return !value.isEmpty
		case  let value as [Any]:
			return !value.isEmpty
		case let value as [AnyHashable: Any]:
			return !value.isEmpty
		default:
			return false
		}
	}
}

/// Wrap the specified data instance in a view model
///
/// - parameter model: A data instance
///
/// - returns: A view model wrapping the data
public func vm<T: ViewModel>(_ model: T.Model) -> T {
	return T(model)
}

/// Wrap the specified data instance in a view model (handles optionals)
///
/// - parameter model: An optional data instance
///
/// - returns: A view model wrapping the data (or nil)
public func vm<T: ViewModel>(_ model: T.Model?) -> T? {
	return T(model)
}
