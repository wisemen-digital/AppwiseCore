//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import UIKit

/// Internal class for keeping track if a registered deeplink item is visible or not.
class DeepLinkMonitorBehaviour: ViewControllerLifeCycleBehaviour {
	weak var matchable: DeepLinkMatchable?
	var stackToRestore: [DeepLinkStackItem] = []
	var wasTabBarVisible = false

	init(_ matchable: DeepLinkMatchable, for path: String) {
		self.matchable = matchable
		stackToRestore = [
			DeepLinkStackItem(path: path, matchable: matchable)
		]
	}

	func afterAppearing(viewController _: UIViewController, animated _: Bool) {
		guard matchable != nil else { return }
		DeepLinker.shared.addToStack(items: stackToRestore)
	}

	func beforeDisappearing(viewController: UIViewController, animated _: Bool) {
		if let tbc = viewController.tabBarController,
		   let selected = tbc.selectedViewController,
		   viewController == selected || viewController.navigationController == selected {
			wasTabBarVisible = true
		} else {
			wasTabBarVisible = false
		}
	}

	func afterDisappearing(viewController: UIViewController, animated _: Bool) {
		guard let matchable else { return }

		if wasTabBarVisible,
		   let tbc = viewController.tabBarController,
		   let selected = tbc.selectedViewController,
		   viewController != selected && viewController.navigationController != selected {
			if let nvc = viewController.navigationController {
				// switching tabs, have a NVC (need to remove all VCs in NVC)
				let controllers = collectControllers(in: nvc)
				stackToRestore = DeepLinker.shared.removeFromStack(items: controllers)
			} else {
				// switching tabs, don't have a NVC
				stackToRestore = DeepLinker.shared.removeFromStack(items: [matchable])
			}
		} else if !wasTabBarVisible,
		          viewController.isBeingDismissed || rootParent(for: viewController).isMovingFromParent {
			// dismissing modal
			stackToRestore = DeepLinker.shared.removeFromStack(items: [matchable])
		}
	}

	private func rootParent(for viewController: UIViewController) -> UIViewController {
		var root = viewController
		while let parent = root.parent {
			root = parent
		}

		return root
	}

	// collect child VCs that are DeeplinkMatchable
	private func collectControllers(in parent: UIViewController) -> [DeepLinkMatchable] {
		parent.children
			.flatMap { [$0] + collectControllers(in: $0) }
			.compactMap { $0 as? DeepLinkMatchable }
	}
}
