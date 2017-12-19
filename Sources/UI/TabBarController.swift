//
//  TabBarController.swift
//  AppwiseCore
//
//  Created by David Jennes on 25/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import UIKit

open class TabBarController: UITabBarController {
	open override var shouldAutorotate: Bool {
		return selectedViewController?.shouldAutorotate ?? super.shouldAutorotate
	}

	open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
	}

	open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return selectedViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
	}

	open override var childViewControllerForStatusBarStyle: UIViewController? {
		return selectedViewController
	}

	open override var childViewControllerForStatusBarHidden: UIViewController? {
		return selectedViewController
	}
}
