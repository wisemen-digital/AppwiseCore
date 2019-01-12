//
//  DismissKeyboardBehaviour.swift
//  AppwiseCore
//
//  Created by David Jennes on 01/12/2017.
//  Copyright © 2019 Appwise. All rights reserved.
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
