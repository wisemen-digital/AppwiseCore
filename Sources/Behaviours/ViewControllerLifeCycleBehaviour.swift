//
//  ViewControllerLifecycleBehaviour.swift
//  AppwiseCore
//
//  Created by Tom Knapen on 23/12/2016.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Then
import UIKit

public protocol ViewControllerLifeCycleBehaviour {
	func afterLoading(viewController: UIViewController)
	
	func beforeAppearing(viewController: UIViewController, animated: Bool)
	func afterAppearing(viewController: UIViewController, animated: Bool)
	
	func beforeDisappearing(viewController: UIViewController, animated: Bool)
	func afterDisappearing(viewController: UIViewController, animated: Bool)
	
	func beforeLayingOutSubviews(viewController: UIViewController)
	func afterLayingOutSubviews(viewController: UIViewController)

	func beforeTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
	func whileTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
	func afterTransitioning(viewController: UIViewController, to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
}

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
