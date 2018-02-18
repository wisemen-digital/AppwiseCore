//
//  KeyboardManagerApplicationService.swift
//  Example
//
//  Created by David Jennes on 04/12/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import AppwiseCore
import IQKeyboardManagerSwift

final class KeyboardManagerApplicationService: NSObject, ApplicationService {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		IQKeyboardManager.sharedManager().enable = true

		return true
	}
}
