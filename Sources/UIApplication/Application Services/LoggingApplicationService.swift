//
//  AppDelegate.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CocoaLumberjack

/// Internal class for initializing the logging framework
final class LoggingApplicationService: NSObject, ApplicationService {
	// swiftlint:disable:next discouraged_optional_collection
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		if let tty = DDTTYLogger.sharedInstance {
			tty.colorsEnabled = true
			DDLog.add(tty)
		}

		DDLog.add(SentryLogger.shared)

		return true
	}
}
