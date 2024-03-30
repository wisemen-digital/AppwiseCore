//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import CloudKit
import UIKit

// swiftlint:disable type_body_length

/// An implementation of the application delegate, that automatically integrates with application services and the `Config` you provide.
///
/// Expects a generic parameter for the type of `Config` you'll be using.
open class AppDelegate<ConfigType: Config>: UIResponder, UIApplicationDelegate {
	/// The shared application delegate
	@available(iOSApplicationExtension, unavailable)
	public static var shared: AppDelegate {
		let result = UIApplication.shared.delegate as? AppDelegate
		return result.require(hint: "Unable to cast app delegate to correct type")
	}

	/// The application's window
	public var window: UIWindow?

	/// The list of application services, empty by default
	open var services: [ApplicationService] { [] }
	private lazy var internalServices: [ApplicationService] = [
		LoggingApplicationService(),
		AddSkipBackupAttributeApplicationService(),
		ConfigureMainQueueApplicationService(),
		ConfigurationApplicationService<ConfigType>()
	]
	private lazy var allServices: [ApplicationService] = self.services + self.internalServices

	/// The document directory of your application
	@available(*, deprecated, message: "Please use FileManager.default.documentsDirectory instead")
	public var documentsDirectory: URL {
		FileManager.default.documentsDirectory.require(hint: "Application requires a documents directory")
	}

	// The support directory of your application
	@available(*, deprecated, message: "Please use FileManager.default.supportDirectory instead")
	public var supportDirectory: URL {
		FileManager.default.supportDirectory.require(hint: "Application requires an application support directory")
	}

	// MARK: UIApplicationDelegate

	// Based on https://github.com/fmo91/PluggableApplicationDelegate
	// Last synced on 8 November 2017, commit 465ebe3
	// swiftlint:disable discouraged_optional_boolean discouraged_optional_collection

	public func applicationDidFinishLaunching(_ application: UIApplication) {
		for service in allServices {
			service.applicationDidFinishLaunching?(application)
		}
	}

	public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		var result = false
		for service in allServices where service.application?(application, willFinishLaunchingWithOptions: launchOptions) ?? false {
			result = true
		}

		return result
	}

	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		var result = false
		for service in allServices where service.application?(application, didFinishLaunchingWithOptions: launchOptions) ?? false {
			result = true
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

	public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		var result = false
		for service in allServices where service.application?(app, open: url, options: options) ?? false {
			result = true
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
	public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
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
		allServices.apply({ service, completion -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, for: notification) { completion(completionHandler) }
		}, then: { _ in
			completionHandler()
		})
	}

	@available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ (service, _: @escaping (()) -> Void) -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo, withResponseInfo: responseInfo, completionHandler: completionHandler)
		}, then: { _ in
			completionHandler()
		})
	}

	@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ service, completion -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, forRemoteNotification: userInfo) { completion(completionHandler) }
		}, then: { _ in
			completionHandler()
		})
	}

	@available(iOS, introduced: 9.0, deprecated: 10.0, message: "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")
	public func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ service, completion -> Void? in
			service.application?(application, handleActionWithIdentifier: identifier, for: notification, withResponseInfo: responseInfo) { completion(completionHandler) }
		}, then: { _ in
			completionHandler()
		})
	}

	public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
		allServices.apply({ service, completionHandler -> Void? in
			service.application?(application, didReceiveRemoteNotification: userInfo, fetchCompletionHandler: completionHandler)
		}, then: { results in
			let result = results.min { $0.rawValue < $1.rawValue } ?? .noData
			completionHandler(result)
		})
	}

	public func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void) {
		allServices.apply({ service, completionHandler -> Void? in
			service.application?(application, performFetchWithCompletionHandler: completionHandler)
		}, then: { results in
			let result = results.min { $0.rawValue < $1.rawValue } ?? .noData
			completionHandler(result)
		})
	}

	public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Swift.Void) {
		allServices.apply({ service, completionHandler -> Void? in
			service.application?(application, performActionFor: shortcutItem, completionHandler: completionHandler)
		}, then: { results in
			// if any service handled the shortcut, return true
			let result = results.contains { $0 }
			completionHandler(result)
		})
	}

	public func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Swift.Void) {
		allServices.apply({ service, completion -> Void? in
			service.application?(application, handleEventsForBackgroundURLSession: identifier) { completion(completionHandler) }
		}, then: { _ in
			completionHandler()
		})
	}

	public func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?, reply: @escaping ([AnyHashable: Any]?) -> Swift.Void) {
		for service in allServices {
			service.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
		}
		allServices.apply({ service, reply -> Void? in
			service.application?(application, handleWatchKitExtensionRequest: userInfo, reply: reply)
		}, then: { results in
			let result = results.reduce(into: [:]) { initial, next in
				for (key, value) in next ?? [:] {
					initial[key] = value
				}
			}
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

	public func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
		var result = false
		for service in allServices where service.application?(application, shouldAllowExtensionPointIdentifier: extensionPointIdentifier) ?? true {
			result = true
		}
		return result
	}

	#if swift(>=4.2)
	public func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
		for service in allServices {
			if let viewController = service.application?(application, viewControllerWithRestorationIdentifierPath: identifierComponents, coder: coder) {
				return viewController
			}
		}

		return nil
	}
	#else
	public func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
		for service in allServices {
			if let viewController = service.application?(application, viewControllerWithRestorationIdentifierPath: identifierComponents, coder: coder) {
				return viewController
			}
		}

		return nil
	}
	#endif

	public func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
		var result = false
		for service in allServices where service.application?(application, shouldSaveApplicationState: coder) ?? false {
			result = true
		}
		return result
	}

	public func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
		var result = false
		for service in allServices where service.application?(application, shouldRestoreApplicationState: coder) ?? false {
			result = true
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
		for service in allServices where service.application?(application, willContinueUserActivityWithType: userActivityType) ?? false {
			result = true
		}
		return result
	}

	public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Swift.Void) -> Bool {
		let returns = allServices.apply({ service, restorationHandler -> Bool? in
			service.application?(application, continue: userActivity, restorationHandler: restorationHandler)
		}, then: { results in
			let result = results.reduce(into: []) { $0.append(contentsOf: $1 ?? []) }
			restorationHandler(result)
		})

		return returns.contains { $0 }
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
	public func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
		for service in allServices {
			service.application?(application, userDidAcceptCloudKitShareWith: cloudKitShareMetadata)
		}
	}

	// swiftlint:enable discouraged_optional_boolean discouraged_optional_collection
}
// swiftlint:enable type_body_length
