//
//  AppDelegate.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Async
import CocoaLumberjack
import CrashlyticsRecorder
import UIKit

open class AppDelegate<ConfigType: Config>: UIResponder, UIApplicationDelegate {
	public static var shared: AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}

	public var window: UIWindow?
	public let documentsDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
	public let supportDirectory: URL = {
		let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
		var name = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
		name = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
		return URL(string: name, relativeTo: dir)!
	}()

	open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

		// some initialization
		DispatchQueue.configureMainQueue()
		setupLogging()
		Async.background { [unowned self] in
			self.addSkipBackupAttributeToAppSupportDirectory()
		}

		return true
	}

	open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		// Fabric
		if CrashlyticsRecorder.sharedInstance == nil {
			DDLogError("CrashlyticsRecorder instance is missing!")
		}

		// load configuration
		ConfigType.shared.setupApplication()

		return true
	}
}

private extension AppDelegate {
	func setupLogging() {
		if let tty = DDTTYLogger.sharedInstance {
			tty.colorsEnabled = true
			DDLog.add(tty)
		}

		if let _ = CrashlyticsRecorder.sharedInstance {
			DDLog.add(CrashlyticsLogger.shared)
		}
	}

	func addSkipBackupAttributeToAppSupportDirectory() {
		do {
			let mgr = FileManager.default

			// create support directory if needed
			if (!mgr.fileExists(atPath: supportDirectory.path)) {
				try mgr.createDirectory(at: supportDirectory, withIntermediateDirectories: true, attributes: nil)
			}

			// add skip attribute
			try (supportDirectory as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
		} catch let error {
			DDLogError("Error excluding support directory from backup: \(error)")
		}
	}
}
