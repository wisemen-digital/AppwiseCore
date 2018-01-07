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
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		if let tty = DDTTYLogger.sharedInstance {
			tty.colorsEnabled = true
			DDLog.add(tty)
		}

		if let _ = CrashlyticsRecorder.sharedInstance {
			DDLog.add(CrashlyticsLogger.shared)
		}

		return true
	}

	func applicationDidFinishLaunching(_ application: UIApplication) {
		if CrashlyticsRecorder.sharedInstance == nil {
			DDLogError("CrashlyticsRecorder instance is missing!")
		}
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		if CrashlyticsRecorder.sharedInstance == nil {
			DDLogError("CrashlyticsRecorder instance is missing!")
		}

		return true
	}
}
