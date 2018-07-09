//
//  AppDelegate.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Foundation
import UIKit

/// Internal class responsible for linking the app delegate with the Config.
final class ConfigurationApplicationService<ConfigType: Config>: NSObject, ApplicationService {
	func applicationDidFinishLaunching(_ application: UIApplication) {
		ConfigType.shared.setupApplication()
	}

	// swiftlint:disable:next discouraged_optional_collection
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
		ConfigType.shared.setupApplication()

		return true
	}
}
