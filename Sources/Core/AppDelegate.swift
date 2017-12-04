//
//  AppDelegate.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CloudKit
import UIKit

extension UIApplication {
	public var documentsDirectory: URL? {
		return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
	}

	public var supportDirectory: URL? {
		guard let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last,
			let name = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String,
			let escaped = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return nil }

		return URL(string: escaped, relativeTo: dir)
	}
}

// Based on https://github.com/fmo91/PluggableApplicationDelegate

open class AppDelegate<ConfigType: Config>: UIResponder, UIApplicationDelegate {
	public static var shared: AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}

	public var window: UIWindow?
	open var services: [ApplicationService] { return [] }
	private lazy var internalServices: [ApplicationService] = [
		LoggingApplicationService(),
		AddSkipBackupAttributeApplicationService(),
		ConfigureMainQueueApplicationService(),
		ConfigurationApplicationService<ConfigType>()
	]
	private lazy var allServices: [ApplicationService] = {
		return self.services + self.internalServices
	}()

	public let documentsDirectory: URL = UIApplication.shared.documentsDirectory.require(hint: "Application requires a documents directory")
	public let supportDirectory: URL = UIApplication.shared.supportDirectory.require(hint: "Application requires an application support directory")

	// MARK: UIApplicationDelegate

	public func applicationDidFinishLaunching(_ application: UIApplication) {
		for service in allServices {
			service.applicationDidFinishLaunching?(application)
		}
	}

	public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		var result = false
		for service in allServices {
			if service.application?(application, willFinishLaunchingWithOptions: launchOptions) ?? false {
				result = true
			}
		}

		return result
	}

	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		var result = false
		for service in allServices {
			if service.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? false {
				result = true
			}
		}

		return result
	}

	public func applicationDidBecomeActive(_ application: UIApplication) {
		for service in allServices {
			service.applicationDidBecomeActive?(application)
		}
	}

	public func applicationWillResignActive(_ application: UIApplication) {
		for service in allServices {
			service.applicationWillResignActive?(application)
		}
	}
	
	public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		var result = false
		for service in allServices {
			if service.application?(app, open: url, options: options) ?? false {
				result = true
			}
		}
		return result
	}

	public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
		for service in allServices {
			service.applicationDidReceiveMemoryWarning?(application)
		}
	}

	public func applicationWillTerminate(_ application: UIApplication) {
		for service in allServices {
			service.applicationWillTerminate?(application)
		}
	}

	public func applicationSignificantTimeChange(_ application: UIApplication) {
		for service in allServices {
			service.applicationSignificantTimeChange?(application)
		}
	}


	public func application(_ application: UIApplication, willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation, duration: TimeInterval) {
		for service in allServices {
			service.application?(application, willChangeStatusBarOrientation: newStatusBarOrientation, duration: duration)
		}
	}

	public func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation) {
		for service in allServices {
			service.application?(application, didChangeStatusBarOrientation: oldStatusBarOrientation)
		}
	}

	public func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
		for service in allServices {
			service.application?(application, willChangeStatusBarFrame: newStatusBarFrame)
		}
	}

	public func application(_ application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect) {
		for service in allServices {
			service.application?(application, didChangeStatusBarFrame: oldStatusBarFrame)
		}
	}

	@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotification UNNotification Settings instead")
	public func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
		for service in allServices {
			service.application?(application, didRegister: notificationSettings)
		}
	}

	public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		for service in allServices {
			service.application?(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
		}
	}

	public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		for service in allServices {
			service.application?(application, didFailToRegisterForRemoteNotificationsWithError: error)
		}
	}

	@available(iOS, introduced: 3.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:] for user visible notifications and -[UIApplicationDelegate application:didReceiveRemoteNotification:fetchCompletionHandler:] for silent remote notifications")
	public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
		for service in allServices {
			service.application?(application, didReceiveRemoteNotification: userInfo)
		}
	}

	@available(iOS, introduced: 4.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate willPresentNotification:withCompletionHandler:] or -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
		for service in allServices {
			service.application?(application, didReceive: notification)
		}
	}


	@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ (service, completion: @escaping (()) -> Void) -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, for: notification, completionHandler: completion)
		}, completionHandler: { _ in
			completionHandler()
		})
	}


	@available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ (service, completion: @escaping (()) -> Void) -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, withResponseInfo: responseInfo, completionHandler: completionHandler)
		}, completionHandler: { _ in
			completionHandler()
		})
	}

	@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ (service, completionHandler: @escaping (()) -> Void) -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, completionHandler: completionHandler)
		}, completionHandler: { _ in
			completionHandler()
		})
	}

	@available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ (service, completionHandler: @escaping (()) -> Void) -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, for: notification, withResponseInfo: responseInfo, completionHandler: completionHandler)
		}, completionHandler: { _ in
			completionHandler()
		})
	}

	public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
		allServices.apply({ (service, completionHandler) -> Void? in
			service.application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
		}, completionHandler: { results in
			let result = results.min(by: { $0.rawValue < $1.rawValue }) ?? .noData
			completionHandler(result)
		})
	}

	public func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
		allServices.apply({ (service, completionHandler) -> Void? in
			service.application?(application, performFetchWithCompletionHandler: completionHandler)
		}, completionHandler: { results in
			let result = results.min(by: { $0.rawValue < $1.rawValue }) ?? .noData
			completionHandler(result)
		})
	}

	public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Swift.Void) {
		allServices.apply({ (service, completionHandler) -> Void? in
			service.application?(application, performActionFor: shortcutItem, completionHandler: completionHandler)
		}, completionHandler: { results in
			// if any service handled the shortcut, return true
			let result = results.reduce(false, { $0 || $1 })
			completionHandler(result)
		})
	}

	public func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ (service, completionHandler: @escaping (()) -> Void) -> Void? in
			service.application?(application, handleEventsForBackgroundURLSession: identifier, completionHandler: completionHandler)
		}, completionHandler: { _ in
			completionHandler()
		})
	}

	public func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable : Any]?, reply: @escaping ([AnyHashable : Any]?) -> Swift.Void) {
		for service in allServices {
			service.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
		}
		allServices.apply({ (service, reply) -> Void? in
			service.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
		}, completionHandler: { results in
			let result = results.reduce([:], { initial, next in
				var initial = initial
				for (key, value) in next ?? [:] {
					initial[key] = value
				}
				return initial
			})
			reply(result)
		})
	}

	public func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
		for service in allServices {
			service.applicationShouldRequestHealthAuthorization?(application)
		}
	}

	public func applicationDidEnterBackground(_ application: UIApplication) {
		for service in allServices {
			service.applicationDidEnterBackground?(application)
		}
	}

	public func applicationWillEnterForeground(_ application: UIApplication) {
		for service in allServices {
			service.applicationWillEnterForeground?(application)
		}
	}

	public func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
		for service in allServices {
			service.applicationProtectedDataWillBecomeUnavailable?(application)
		}
	}

	public func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
		for service in allServices {
			service.applicationProtectedDataDidBecomeAvailable?(application)
		}
	}

	public func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
		var result = false
		for service in allServices {
			if service.application?(application, shouldAllowExtensionPointIdentifier: extensionPointIdentifier) ?? true {
				result = true
			}
		}
		return result
	}

	public func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
		for service in allServices {
			if let viewController = service.application?(application, viewControllerWithRestorationIdentifierPath: identifierComponents, coder: coder) {
				return viewController
			}
		}

		return nil
	}

	public func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		var result = false
		for service in allServices {
			if service.application?(application, shouldSaveApplicationState: coder) ?? false {
				result = true
			}
		}
		return result
	}

	public func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
		var result = false
		for service in allServices {
			if service.application?(application, shouldRestoreApplicationState: coder) ?? false {
				result = true
			}
		}
		return result
	}

	public func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
		for service in allServices {
			service.application?(application, willEncodeRestorableStateWith: coder)
		}
	}

	public func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
		for service in allServices {
			service.application?(application, didDecodeRestorableStateWith: coder)
		}
	}

	public func application(_ application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
		var result = false
		for service in allServices {
			if service.application?(application, willContinueUserActivityWithType: userActivityType) ?? false {
				result = true
			}
		}
		return result
	}

	public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Swift.Void) -> Bool {
		let returns = allServices.apply({ (service, restorationHandler) -> Bool? in
			service.application?(application, continue: userActivity, restorationHandler: restorationHandler)
		}, completionHandler: { results in
			let result = results.reduce([], { $0 + ($1 ?? []) })
			restorationHandler(result)
		})

		return returns.reduce(false, { $0 || $1 })
	}

	public func application(_ application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: Error) {
		for service in allServices {
			service.application?(application, didFailToContinueUserActivityWithType: userActivityType, error: error)
		}
	}

	public func application(_ application: UIApplication, didUpdate userActivity: NSUserActivity) {
		for service in allServices {
			service.application?(application, didUpdate: userActivity)
		}
	}

	@available(iOS 10.0, *)
	public func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShareMetadata) {
		for service in allServices {
			service.application?(application, userDidAcceptCloudKitShareWith: cloudKitShareMetadata)
		}
	}
}
