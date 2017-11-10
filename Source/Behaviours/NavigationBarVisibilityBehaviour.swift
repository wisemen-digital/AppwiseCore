//
//  HideShowNavigationBarBehaviour.swift
//  AppwiseCore
//
//  Created by Tom Knapen on 23/12/2016.
//  Copyright © 2017 Appwise. All rights reserved.
//

import UIKit

struct HideShowNavigationBarBehaviour: ViewControllerLifeCycleBehaviour {
	enum Mode {
	case hide
	case show
	}

	let mode: Mode

	func beforeAppearing(viewController: UIViewController, animated: Bool) {
		switch mode {
		case .hide:
			viewController.navigationController?.setNavigationBarHidden(true, animated: animated)
		case .show:
			viewController.navigationController?.setNavigationBarHidden(false, animated: animated)
		}
	}

	func beforeDisappearing(viewController: UIViewController, animated: Bool) {
		switch mode {
		case .hide:
			viewController.navigationController?.setNavigationBarHidden(false, animated: animated)
		case .show:
			viewController.navigationController?.setNavigationBarHidden(true, animated: animated)
		}
	}
}
