//
//  AppDelegate.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Foundation

final class ConfigurationApplicationService<ConfigType: Config>: NSObject, ApplicationService {
	func applicationDidFinishLaunching(_ application: UIApplication) {
		ConfigType.shared.setupApplication()
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		ConfigType.shared.setupApplication()

		return true
	}
}
