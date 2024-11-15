//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Then
import UIKit

/// Types adopting the `ViewControllerLifeCycleBehaviour` protocol can be used to add behaviours to a view controller,
/// which are used to react to changes during it's life cycle.
public protocol ViewControllerLifeCycleBehaviour {
	/// Called at the end of `viewDidLoad()`
	func afterLoading(viewController: UIViewController)

	/// Called at the end of `viewWillAppear(_:)`
	func beforeAppearing(viewController: UIViewController, animated: Bool)

	/// Called at the end of `viewDidAppear(_:)`
	func afterAppearing(viewController: UIViewController, animated: Bool)

	/// Called at the end of `viewWillDisappear(_:)`
	func beforeDisappearing(viewController: UIViewController, animated: Bool)

	/// Called at the end of `viewDidDisappear(_:)`
	func afterDisappearing(viewController: UIViewController, animated: Bool)

	/// Called at the end of `viewWillLayoutSubviews(_:)`
	func beforeLayingOutSubviews(viewController: UIViewController)

	/// Called at the end of `viewDidLayoutSubviews(_:)`
	func afterLayingOutSubviews(viewController: UIViewController)

	/// Called at the start of `viewWillTransition(to:, with:)`
	func beforeTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)

	/// Called during the animation of `viewWillTransition(to:, with:)`
	func whileTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)

	/// Called at the end of `viewWillTransition(to:, with:)`
	func afterTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

/// Default empty implementations
public extension ViewControllerLifeCycleBehaviour {
	func afterLoading(viewController _: UIViewController) {}

	func beforeAppearing(viewController _: UIViewController, animated _: Bool) {}
	func afterAppearing(viewController _: UIViewController, animated _: Bool) {}

	func beforeDisappearing(viewController _: UIViewController, animated _: Bool) {}
	func afterDisappearing(viewController _: UIViewController, animated _: Bool) {}

	func beforeLayingOutSubviews(viewController _: UIViewController) {}
	func afterLayingOutSubviews(viewController _: UIViewController) {}

	func beforeTransitioning(viewController _: UIViewController, to _: CGSize, with _: UIViewControllerTransitionCoordinator) {}
	func whileTransitioning(viewController _: UIViewController, to _: CGSize, with _: UIViewControllerTransitionCoordinator) {}
	func afterTransitioning(viewController _: UIViewController, to _: CGSize, with _: UIViewControllerTransitionCoordinator) {}
}

public extension UIViewController {
	/// Add a list of behaviours to this view controller, they will be invoked in the same order as provided here.
	///
	/// - parameter behaviours: List of life cycle behaviours.
	///
	/// Important: Do not add lifecycle behaviours to `UINavigationController` or `UITabBarController` instances,
	///   as this will break their layout.
	func add(behaviours: [ViewControllerLifeCycleBehaviour]) {
		guard !behaviours.isEmpty else { return }
		let behaviourViewController = LifecycleBehaviourViewController(behaviours: behaviours)

		addChild(behaviourViewController)
		behaviourViewController.view?.do {
			$0.frame = view.bounds
			$0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			$0.translatesAutoresizingMaskIntoConstraints = true
			view.addSubview($0)
		}
		behaviourViewController.didMove(toParent: self)
	}
}
