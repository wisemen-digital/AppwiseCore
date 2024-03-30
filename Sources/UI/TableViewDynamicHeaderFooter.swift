//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import UIKit

/// Header (or footer) view for in a UITableView, that will automatically resize itself
/// to fit its content, with the help of the accompanying `DynamicHeaderFooterBehaviour`.
///
/// Note: The content view's bottom edge should not be constrained to it's parent
///       view so that it can grow freely in height.
open class ResizableTableHeaderFooterView: UIView {
	@IBOutlet private var contentView: UIView?

	fileprivate func resizeToMatchContent(completion: @escaping (() -> Void)) {
		guard let contentView,
		      contentView.bounds.height != bounds.height else { return }

		// Set the height to be the content's height,
		// dynamically calculated using constraints
		var rect = frame
		rect.size.height = contentView.bounds.height
		frame = rect

		DispatchQueue.main.async(execute: completion)
	}
}

public extension UITableView {
	/// Update the height of the header view to match its content's height, if it is
	/// a `ResizableTableHeaderFooterView`.
	func updateHeaderViewHeight() {
		guard let view = tableHeaderView as? ResizableTableHeaderFooterView else { return }

		view.resizeToMatchContent { [weak self] in
			self?.tableHeaderView = view
		}
	}

	/// Update the height of the footer view to match its content's height, if it is
	/// a `ResizableTableHeaderFooterView`.
	func updateFooterViewHeight() {
		guard let view = tableFooterView as? ResizableTableHeaderFooterView else { return }

		view.resizeToMatchContent { [weak self] in
			self?.tableFooterView = view
		}
	}
}

/// Behaviour to resize the header and/or footer views of a `UITableView` to match their
/// content, works in conjunction with `ResizableTableHeaderFooterView`.
public struct DynamicHeaderFooterBehaviour: ViewControllerLifeCycleBehaviour {
	weak var tableView: UITableView?

	/// Creates a new instance with the specified foreground and background closures.
	///
	/// - parameter tableView: The table view whose headers/footers we should monitor.
	///
	/// - returns: The new behaviour instance.
	public init(tableView: UITableView) {
		self.tableView = tableView
	}

	public func beforeAppearing(viewController: UIViewController, animated: Bool) {
		tableView?.updateHeaderViewHeight()
		tableView?.updateFooterViewHeight()
	}

	public func afterAppearing(viewController: UIViewController, animated: Bool) {
		tableView?.updateHeaderViewHeight()
		tableView?.updateFooterViewHeight()
	}

	public func afterLayingOutSubviews(viewController: UIViewController) {
		// Delay this a bit, to avoid layout issues (header shrinking and such...)
		DispatchQueue.main.async {
			tableView?.updateHeaderViewHeight()
			tableView?.updateFooterViewHeight()
		}
	}
}
