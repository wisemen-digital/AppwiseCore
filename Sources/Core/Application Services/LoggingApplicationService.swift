//
//  AppDelegate.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CocoaLumberjack
import CrashlyticsRecorder

/// Internal class for initializing the logging framework
final class LoggingApplicationService: NSObject, ApplicationService {
	// swiftlint:disable:next discouraged_optional_collection
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		if let tty = DDTTYLogger.sharedInstance {
			tty.colorsEnabled = true
			DDLog.add(tty)
		}

		if CrashlyticsRecorder.sharedInstance != nil {
			DDLog.add(CrashlyticsLogger.shared)
		}

		return true
	}

	func applicationDidFinishLaunching(_ application: UIApplication) {
		if CrashlyticsRecorder.sharedInstance == nil {
			DDLogError("CrashlyticsRecorder instance is missing!")
		}
	}

	// swiftlint:disable:next discouraged_optional_collection
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		if CrashlyticsRecorder.sharedInstance == nil {
			DDLogError("CrashlyticsRecorder instance is missing!")
		}

		return true
	}
}
