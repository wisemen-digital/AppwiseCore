//
// AppwiseCore
// Copyright © 2026 Wisemen
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

	override open var childForStatusBarStyle: UIViewController? {
		selectedViewController
	}

	override open var childForStatusBarHidden: UIViewController? {
		selectedViewController
	}
}
