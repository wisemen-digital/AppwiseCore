//
//  NavigationController.swift
//  AppwiseCore
//
//  Created by David Jennes on 25/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import UIKit

/// UINavigationController that passes calls for orientation and status bar to it's top
/// view controller.
open class NavigationController: UINavigationController {
	override open var shouldAutorotate: Bool {
		return topViewController?.shouldAutorotate ?? super.shouldAutorotate
	}

	override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
	}

	override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return topViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
	}

	#if swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0))
	override open var childForStatusBarStyle: UIViewController? {
		return topViewController
	}

	override open var childForStatusBarHidden: UIViewController? {
		return topViewController
	}
	#else
	override open var childViewControllerForStatusBarStyle: UIViewController? {
		return topViewController
	}

	override open var childViewControllerForStatusBarHidden: UIViewController? {
		return topViewController
	}
	#endif
}
