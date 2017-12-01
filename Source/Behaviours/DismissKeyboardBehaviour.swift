//
//  DismissKeyboardBehaviour.swift
//  AppwiseCore
//
//  Created by David Jennes on 01/12/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import UIKit

struct DismissKeyboardBehaviour: ViewControllerLifeCycleBehaviour {
	func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		viewController.view.endEditing(true)
	}
}
