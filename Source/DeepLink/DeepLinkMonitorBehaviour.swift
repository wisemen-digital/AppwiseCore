//
//  DeepLinkMonitorBehaviour.swift
//  AppwiseCore
//
//  Created by David Jennes on 10/11/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import UIKit

struct DeepLinkMonitorBehaviour: ViewControllerLifeCycleBehaviour {
	let path: String
	weak var matchable: DeepLinkMatchable?

	func afterLoading(viewController: UIViewController) {
		print("after loading")
	}

	func beforeAppearing(viewController: UIViewController, animated: Bool) {
		print("before appearing")
		guard let matchable = matchable else { return }
		DeepLinker.shared.addToStack(matchable, for: path)
	}

	func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		guard viewController.isBeingDismissed || viewController.isMovingFromParentViewController,
			let matchable = matchable else { return }
		DeepLinker.shared.removeFromStack(matchable)
	}
}
