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
	
	// Empty definitions to avoid selector mismatch due to generic name mangling
	
	open func applicationDidBecomeActive(_ application: UIApplication) {}
	open func applicationWillResignActive(_ application: UIApplication) {}
	open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool { return true }
	open func applicationDidReceiveMemoryWarning(_ application: UIApplication) {}
	open func applicationWillTerminate(_ application: UIApplication) {}
	open func applicationSignificantTimeChange(_ application: UIApplication) {}
	open func application(_ application: UIApplication, willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation, duration: TimeInterval) {}
	open func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {}
	open func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {}
	open func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {}
	open func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {}
	open func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {}
	open func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {}
	open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {}
	open func application(_ application: UIApplication, didReceive notification: UILocalNotification) {}
	open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Swift.Void) {}
	open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {}
	open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {}
	open func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {}
	open func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {}
	open func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {}
	open func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Swift.Void) {}
	open func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Swift.Void) {}
	open func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Swift.Void) {}
	open func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {}
	open func applicationDidEnterBackground(_ application: UIApplication) {}
	open func applicationWillEnterForeground(_ application: UIApplication) {}
	open func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {}
	open func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {}
	open func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool { return true }
	open func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? { return nil }
	open func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool { return false }
	open func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool { return false }
	open func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {}
	open func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {}
	open func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool { return true }
	open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool { return true }
	open func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {}
	open func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {}
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
