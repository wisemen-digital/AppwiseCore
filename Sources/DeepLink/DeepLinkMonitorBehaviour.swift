//
//  DeepLinkMonitorBehaviour.swift
//  AppwiseCore
//
//  Created by David Jennes on 10/11/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import UIKit

/// Internal class for keeping track if a registered deeplink item is visible or not.
class DeepLinkMonitorBehaviour: ViewControllerLifeCycleBehaviour {
	let path: String
	weak var matchable: DeepLinkMatchable?
	var wasTabBarVisible = false

	init(_ matchable: DeepLinkMatchable, for path: String) {
		self.path = path
		self.matchable = matchable
	}

	func afterAppearing(viewController: UIViewController, animated: Bool) {
		guard let matchable = matchable else { return }
		DeepLinker.shared.addToStack(matchable, for: path)
	}

	func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		if let tbc = viewController.tabBarController,
			let selected = tbc.selectedViewController,
			viewController == selected || viewController.navigationController == selected {
			wasTabBarVisible = true
		} else {
			wasTabBarVisible = false
		}
	}

	func afterDisappearing(viewController: UIViewController, animated: Bool) {
		guard let matchable = matchable else { return }

		if wasTabBarVisible,
			let tbc = viewController.tabBarController,
			let selected = tbc.selectedViewController,
			viewController != selected && viewController.navigationController != selected {
			DeepLinker.shared.removeFromStack(matchable)
		} else if !wasTabBarVisible,
			viewController.isBeingDismissed || rootParent(for: viewController).isMovingFromParentViewController {
			DeepLinker.shared.removeFromStack(matchable)
		}
	}

	private func rootParent(for viewController: UIViewController) -> UIViewController {
		var root = viewController
		while let parent = root.parent {
			root = parent
		}

		return root
	}
}
