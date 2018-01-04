//
//  ViewModel.swift
//  AppwiseCore
//
//  Created by David Jennes on 29/03/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation
import Then

public protocol ViewModel: Then {
	associatedtype Model

	var data: Model! { get set }
	init()
}

public extension ViewModel {
	init(_ data: Model) {
		self.init()
		self.data = data
	}

	init?(_ data: Model?) {
		if let data = data {
			self.init(data)
		} else {
			return nil
		}
	}
}

public extension ViewModel where Model: NSObject {
	func has(_ key: AnyKeyPath) -> Bool {
		guard let value = data[keyPath: key] as? String else { return false }
		return !value.isEmpty
	}
}

public func vm<T: ViewModel>(_ model: T.Model) -> T {
	return T(model)
}

public func vm<T: ViewModel>(_ model: T.Model?) -> T? {
	return T(model)
}
