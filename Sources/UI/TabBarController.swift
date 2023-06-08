//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import UIKit

/// UITabBarController that passes calls for orientation and status bar to it's selected
/// view controller.
open class TabBarController: UITabBarController {
	override open var shouldAutorotate: Bool {
		selectedViewController?.shouldAutorotate ?? super.shouldAutorotate
	}

	override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		selectedViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
	}

	override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		selectedViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
	}

	#if swift(>=4.2)
	override open var childForStatusBarStyle: UIViewController? {
		selectedViewController
	}

	override open var childForStatusBarHidden: UIViewController? {
		selectedViewController
	}
	#else
	override open var childViewControllerForStatusBarStyle: UIViewController? {
		selectedViewController
	}

	override open var childViewControllerForStatusBarHidden: UIViewController? {
		selectedViewController
	}
	#endif
}
