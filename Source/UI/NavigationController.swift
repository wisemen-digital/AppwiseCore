//
//  NavigationController.swift
//  AppwiseCore
//
//  Created by David Jennes on 25/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import UIKit

open class NavigationController: UINavigationController {
	open override var shouldAutorotate: Bool {
		return topViewController?.shouldAutorotate ?? super.shouldAutorotate
	}

	open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
	}

	open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return topViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
	}

	open override var preferredStatusBarStyle: UIStatusBarStyle {
		return topViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
	}
}
