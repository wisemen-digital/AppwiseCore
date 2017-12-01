//
//  DismissKeyboardBehaviour.swift
//  AppwiseCore
//
//  Created by David Jennes on 01/12/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import UIKit

public struct DismissKeyboardBehaviour: ViewControllerLifeCycleBehaviour {
	public init() {
	}

	public func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		viewController.view.endEditing(true)
	}
}
