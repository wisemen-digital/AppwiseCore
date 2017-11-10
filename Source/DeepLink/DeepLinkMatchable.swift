//
//  DeepLinker.swift
//  AppwiseCore
//
//  Created by David Jennes on 03/11/17.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation

public protocol DeepLinkMatchable: class, NSObjectProtocol {
	func dismiss(items: [DeepLinkStackItem]) -> Bool
	func present(link: [String], exists: Bool) -> DeepLinkMatchable?
}

public extension DeepLinkMatchable {
	func dismiss(items: [DeepLinkStackItem]) -> Bool {
		return false
	}
}

public extension DeepLinkMatchable where Self: UIViewController {
	func dismiss(items: [DeepLinkStackItem]) -> Bool {
		return false // TODO
	}
}
