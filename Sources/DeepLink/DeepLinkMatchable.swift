//
//  DeepLinker.swift
//  AppwiseCore
//
//  Created by David Jennes on 03/11/17.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation
import UIKit

public protocol DeepLinkMatchable: class, NSObjectProtocol {
	func dismiss(items: [DeepLinkStackItem], animated: Bool) -> Bool
	func present(link: [String], animated: Bool) -> DeepLinkMatchable?
}

public extension DeepLinkMatchable {
	func dismiss(items: [DeepLinkStackItem], animated: Bool) -> Bool {
		return false
	}
}

public extension DeepLinkMatchable where Self: UIViewController {
	func dismiss(items: [DeepLinkStackItem], animated: Bool) -> Bool {
		return false // TODO
	}
}
