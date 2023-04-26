//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import AppwiseCore
import UIKit

/// Tries to ensure that a scrollview grows to fill the screen, but if a
/// keyboard is shown, the scrollview will shrink (if possible) to avoid the keyboard.
public struct KeyboardStickyBehaviour: ViewControllerLifeCycleBehaviour {
	let content: UIView

	/// Creates a new instance with the specified content view. The given
	/// content view will shrink/expand as needed.
	///
	/// - parameter content: The content view that will be "stuck" to the top of the keyboard.
	///
	/// - returns: The new behaviour instance.
	public init(content: UIView) {
		self.content = content
	}

	public func afterLoading(viewController: UIViewController) {
		if #available(iOS 15.0, *) {
			let constraint = NSLayoutConstraint(item: content, attribute: .bottom, relatedBy: .equal, toItem: viewController.view.keyboardLayoutGuide, attribute: .top, multiplier: 1, constant: 0)
			constraint.priority = .dragThatCanResizeScene
			NSLayoutConstraint.activate([constraint])
		}
	}
}
