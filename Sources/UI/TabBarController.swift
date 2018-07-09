//
//  TabBarController.swift
//  AppwiseCore
//
//  Created by David Jennes on 25/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import UIKit

/// UITabBarController that passes calls for orientation and status bar to it's selected
/// view controller.
open class TabBarController: UITabBarController {
	override open var shouldAutorotate: Bool {
		return selectedViewController?.shouldAutorotate ?? super.shouldAutorotate
	}

	override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
	}

	override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return selectedViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
	}

	override open var childViewControllerForStatusBarStyle: UIViewController? {
		return selectedViewController
	}

	override open var childViewControllerForStatusBarHidden: UIViewController? {
		return selectedViewController
	}
}
