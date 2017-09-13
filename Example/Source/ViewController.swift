//
//  ViewController.swift
//  Example
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		// This will trigger error messages in debug builds
		DispatchQueue.global(qos: .background).async { [weak self] in
			
			self?.view.setNeedsLayout()
			self?.view.setNeedsDisplay()
		}
	}
}
