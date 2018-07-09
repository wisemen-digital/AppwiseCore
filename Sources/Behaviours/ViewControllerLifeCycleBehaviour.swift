//
//  ViewControllerLifecycleBehaviour.swift
//  AppwiseCore
//
//  Created by Tom Knapen on 23/12/2016.
//  Copyright © 2017 Appwise. All rights reserved.
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
	func afterLoading(viewController: UIViewController) {}

	func beforeAppearing(viewController: UIViewController, animated: Bool) {}
	func afterAppearing(viewController: UIViewController, animated: Bool) {}

	func beforeDisappearing(viewController: UIViewController, animated: Bool) {}
	func afterDisappearing(viewController: UIViewController, animated: Bool) {}

	func beforeLayingOutSubviews(viewController: UIViewController) {}
	func afterLayingOutSubviews(viewController: UIViewController) {}

	func beforeTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {}
	func whileTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {}
	func afterTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {}
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

		addChildViewController(behaviourViewController)
		behaviourViewController.view?.do {
			$0.frame = view.bounds
			$0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			$0.translatesAutoresizingMaskIntoConstraints = true
			view.insertSubview($0, at: 0)
		}
		behaviourViewController.didMove(toParentViewController: self)
	}
}
