//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import UIKit

/// Behaviour for hiding (or showing) the navigation bar while the view controller is visible.
public struct HideShowNavigationBarBehaviour: ViewControllerLifeCycleBehaviour {
	/// The display mode to apply while the view controller is visible
	public enum Mode {
		/// In this mode, the navigation bar will be hidden while the VC is visible
		case hide
		/// In this mode, the navigation bar will be shown while the VC is visible
		case show
	}

	let mode: Mode

	/// Creates a new instance with the specified display mode.
	///
	/// - parameter mode: The mode to work in, see `Mode`.
	///
	/// - returns: The new behaviour instance.
	public init(mode: Mode) {
		self.mode = mode
	}

	public func beforeAppearing(viewController: UIViewController, animated: Bool) {
		switch mode {
		case .hide:
			viewController.navigationController?.setNavigationBarHidden(true, animated: animated)
		case .show:
			viewController.navigationController?.setNavigationBarHidden(false, animated: animated)
		}
	}

	public func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		switch mode {
		case .hide:
			viewController.navigationController?.setNavigationBarHidden(false, animated: animated)
		case .show:
			viewController.navigationController?.setNavigationBarHidden(true, animated: animated)
		}
	}
}
