//
//  TableViewDynamicHeaderFooter.swift
//  AppwiseCore
//
//  Created by David Jennes on 01/12/17.
//  Copyright © 2017 Appwise. All rights reserved.
//

import AppwiseCore

// Note: The content view's bottom edge should not be constrained to it's parent
//       view so that it can grow freely in height.
open class ResizableTableHeaderFooterView: UIView {
	@IBOutlet weak var contentView: UIView?

	fileprivate func resizeToMatchContent(completion: @escaping (() -> Void)) {
		guard let contentView = contentView,
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
	func updateHeaderViewHeight() {
		guard let view = self.tableHeaderView as? ResizableTableHeaderFooterView else { return }

		view.resizeToMatchContent() { [weak self] in
			self?.tableHeaderView = view
		}
	}

	func updateFooterViewHeight() {
		guard let view = self.tableFooterView as? ResizableTableHeaderFooterView else { return }

		view.resizeToMatchContent() { [weak self] in
			self?.tableFooterView = view
		}
	}
}

public struct DynamicHeaderFooterBehaviour: ViewControllerLifeCycleBehaviour {
	weak var tableView: UITableView?

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
		tableView?.updateHeaderViewHeight()
		tableView?.updateFooterViewHeight()
	}
}
