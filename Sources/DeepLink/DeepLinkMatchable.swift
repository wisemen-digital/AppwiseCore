//
// AppwiseCore
// Copyright © 2021 Appwise
//

import Foundation
import UIKit

/// Represents something that can be pushed onto the stack of the deep linker, usually a subclass
/// of UIViewController. It should register itself on "load" with the matcher, for example at the
/// end of `viewDidLoad()`.
///
/// Note: You'll also need to implement this protocol even for items you don't want to deep link to,
/// just to make the matcher system aware of what's currently visible and needs to be dismissed.
public protocol DeepLinkMatchable: AnyObject, NSObjectProtocol {
	/// Dismiss a currently visible stack of items
	///
	/// - parameter items: The list of items to dismiss (you only need to dismiss the first one).
	/// - parameter animated: Wether the dismissal should be animated or not.
	///
	/// - returns: True if anything was dismissed.
	func dismiss(items: [DeepLinkStackItem], animated: Bool) -> Bool

	/// Present a stack of identifiers, e.g. path components.
	///
	/// - parameter link: A stack of identifiers to present (you only need to present the first one).
	/// - parameter animated: Wether the presentation should be animated or not.
	///
	/// - returns: The newly created and presented deep link item. Further `present(link:, animated:)`
	/// calls for remaining link path components will be called on this item.
	func present(link: [String], animated: Bool) -> DeepLinkMatchable?
}

public extension DeepLinkMatchable {
	/// Default implementation, just returns false.
	func dismiss(items: [DeepLinkStackItem], animated: Bool) -> Bool {
		false
	}
}

public extension DeepLinkMatchable where Self: UIViewController {
	func dismiss(items: [DeepLinkStackItem], animated: Bool) -> Bool {
		false // TODO: default dismiss of presented or pop nav
	}
}
