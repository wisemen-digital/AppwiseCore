//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import UIKit

public protocol RefreshOnAppearBehaviorDelegate: AnyObject {
	func refresh()
}

// swiftlint:disable:next type_name
public protocol RefreshOnAppearBehaviorDelegateWithControl: AnyObject {
	func refresh(_ control: UIRefreshControl)
}

/// Behaviour for triggering a content refresh on appear.
public final class RefreshOnAppearBehavior: ViewControllerLifeCycleBehaviour {
	/// Controls which appear events trigger a refresh.
	public enum Mode {
		/// Trigger a refresh on each appear
		case always
		/// Trigger a refresh on each appear, excluding appears from a pop-navigation
		case excludingPopNavigation
	}

	private weak var simpleDelegate: RefreshOnAppearBehaviorDelegate?
	private weak var withControlDelegate: RefreshOnAppearBehaviorDelegateWithControl?
	private weak var refreshControl: UIRefreshControl?
	private var mode: Mode
	private var nextAppearIsPopNavigation = false

	/// Creates a new instance with the delegate.
	///
	/// - parameter delegate: Delegate to trigger a content refresh.
	/// - parameter mode: The mode to check when to trigger a refresh, see `Mode` for more information.
	///
	/// - returns: The new behaviour instance.
	public init(delegate: RefreshOnAppearBehaviorDelegate, mode: Mode = .excludingPopNavigation) {
		simpleDelegate = delegate
		withControlDelegate = nil
		refreshControl = nil
		self.mode = mode
	}

	/// Creates a new instance with the delegate.
	///
	/// - parameter delegate: Delegate to trigger a content refresh, with a refresh control.
	/// - parameter refreshControl: The refresh control to pass along to the delegate.
	/// - parameter mode: The mode to check when to trigger a refresh, see `Mode` for more information.
	///
	/// - returns: The new behaviour instance.
	public init(delegate: RefreshOnAppearBehaviorDelegateWithControl, refreshControl: UIRefreshControl, mode: Mode = .excludingPopNavigation) {
		simpleDelegate = nil
		withControlDelegate = delegate
		self.refreshControl = refreshControl
		self.mode = mode
	}

	public func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		if let nvc = viewController.navigationController,
		   let nvcChild = viewController.navigationControllerChild {
			nextAppearIsPopNavigation = (nvc.topViewController != nvcChild)
		} else {
			nextAppearIsPopNavigation = false
		}
	}

	public func beforeAppearing(viewController: UIViewController, animated: Bool) {
		switch mode {
		case .excludingPopNavigation where nextAppearIsPopNavigation:
			break
		default:
			triggerRefresh()
		}
	}

	private func triggerRefresh() {
		if let delegate = simpleDelegate {
			delegate.refresh()
		} else if let delegate = withControlDelegate, let refreshControl {
			delegate.refresh(refreshControl)
		}
	}
}

private extension UIViewController {
	var navigationControllerChild: UIViewController? {
		guard let nvc = navigationController else { return nil }

		if parent == nvc {
			return self
		} else {
			return parent?.navigationControllerChild
		}
	}
}
