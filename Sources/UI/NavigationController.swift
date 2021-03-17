//
// AppwiseCore
// Copyright © 2021 Appwise
//

import UIKit

/// UINavigationController that passes calls for orientation and status bar to it's top
/// view controller.
open class NavigationController: UINavigationController {
	override open var shouldAutorotate: Bool {
		topViewController?.shouldAutorotate ?? super.shouldAutorotate
	}

	override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
	}

	override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		topViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
	}

	#if swift(>=4.2)
	override open var childForStatusBarStyle: UIViewController? {
		topViewController
	}

	override open var childForStatusBarHidden: UIViewController? {
		topViewController
	}
	#else
	override open var childViewControllerForStatusBarStyle: UIViewController? {
		topViewController
	}

	override open var childViewControllerForStatusBarHidden: UIViewController? {
		topViewController
	}
	#endif
}
