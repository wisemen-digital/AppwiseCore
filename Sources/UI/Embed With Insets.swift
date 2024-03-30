//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import UIKit

/// Add this behaviour to the parent controller, to apply insets to the given child controller
@available(iOS 11.0, tvOS 11.0, *)
public struct EmbedInsetsBehaviour: ViewControllerLifeCycleBehaviour {
	private weak var affectedController: UIViewController?
	private var topView: UIView?
	private var bottomView: UIView?

	public init(controller affectedController: UIViewController?, topView: UIView? = nil, bottomView: UIView? = nil) {
		self.affectedController = affectedController
		self.topView = topView
		self.bottomView = bottomView
	}

	public func afterLayingOutSubviews(viewController: UIViewController) {
		affectedController?.additionalSafeAreaInsets = viewController.additionalSafeAreaInsets.with {
			$0.top += topView?.bounds.height ?? CGFloat(0)
			$0.bottom += bottomView?.bounds.height ?? CGFloat(0)
		}
	}
}

/// Use this as a class for a custom segue, and trigger it on `viewDidLoad`.
@available(iOS 11.0, tvOS 11.0, *)
public final class EmbedWithInsetsSegue: UIStoryboardSegue {
	override public func perform() {
		let parentView: UIView = source.view

		source.addChild(destination)
		parentView.insertSubview(destination.view, at: 0)
		destination.didMove(toParent: source)

		destination.view.do {
			$0.translatesAutoresizingMaskIntoConstraints = false
			$0.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
			$0.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 0).isActive = true
			$0.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 0).isActive = true
			$0.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: 0).isActive = true
		}
	}
}
