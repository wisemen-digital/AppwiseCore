//
//  DeepLinker.swift
//  AppwiseCore
//
//  Created by David Jennes on 03/11/17.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

/// A deep link stack item, for connecting an identifier to a matchable item.
public final class DeepLinkStackItem {
	/// The path component
	public let path: String
	/// The corresponding matchable item
	weak var matchable: DeepLinkMatchable?

	init(path: String, matchable: DeepLinkMatchable) {
		self.path = path
		self.matchable = matchable
	}
}

extension Array where Element == DeepLinkStackItem {
	mutating func cleanupWeakReferences() {
		self = filter { item in
			item.matchable != nil
		}
	}

	func removingWeakReferences() -> [DeepLinkStackItem] {
		return self.filter { item in
			item.matchable != nil
		}
	}
}
