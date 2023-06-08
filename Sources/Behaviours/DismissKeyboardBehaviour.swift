//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import UIKit

/// Behaviour for dismissing the keyboard before the view controller disappears.
public struct DismissKeyboardBehaviour: ViewControllerLifeCycleBehaviour {
	/// Creates a new instance.
	///
	/// - returns: The new behaviour instance.
	public init() {
	}

	public func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		viewController.view.endEditing(true)
	}
}
