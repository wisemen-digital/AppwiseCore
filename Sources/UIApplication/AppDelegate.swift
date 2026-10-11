//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CloudKit
import Intents
import UIKit

/// An implementation of the application delegate, that automatically integrates with application plugins (observers) and the `Config` you provide.
///
/// Expects a generic parameter for the type of `Config` you'll be using.
/// Expects a generic parameter for the type of `SceneDelegate` you'll be using, in case it is not set in your `Info.plist`.
open class AppDelegate<ConfigType: Config, SceneDelegateType: SceneDelegate>: UIResponder, UIApplicationDelegate {
	/// The shared application delegate
	@available(iOSApplicationExtension, unavailable)
	public static var shared: AppDelegate {
		let result = UIApplication.shared.delegate as? Self
		return result.require(hint: "Unable to cast app delegate to correct type")
	}

	/// The application's window
	public var window: UIWindow?

	/// The list of application plugins, empty by default
	open var plugins: [ApplicationDelegatePlugin] {
		[]
	}

	private lazy var internalPlugins: [ApplicationDelegatePlugin] = [
		LoggingObserver(),
		AddSkipBackupAttributeObserver(),
		ConfigureMainQueueObserver(),
		ConfigurationObserver<ConfigType>()
	]
	private lazy var allPlugins: [ApplicationDelegatePlugin] = self.plugins + self.internalPlugins

	// MARK: - App Lifecycle

	// swiftlint:disable:next discouraged_optional_collection
	public func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		allPlugins
			.filter(as: ApplicationLifecycleObserver.self)
			.allSatisfy { $0.application(application, willFinishLaunchingWithOptions: launchOptions ?? [:]) }
	}

	// swiftlint:disable:next discouraged_optional_collection
	public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		allPlugins
			.filter(as: ApplicationLifecycleObserver.self)
			.allSatisfy { $0.application(application, didFinishLaunchingWithOptions: launchOptions ?? [:]) }
	}

	public func applicationWillTerminate(_ application: UIApplication) {
		for plugin in allPlugins.filter(as: ApplicationLifecycleObserver.self) {
			plugin.applicationWillTerminate(application)
		}
	}

	// MARK: - Scene Delegate Support

	public func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		// If any delegate provides a config, use that. Otherwise fallback to the config from `Info.plist`, using our scene delegate type if needed
		allPlugins
			.filter(as: ApplicationSceneObserver.self)
			.firstNonNil {
				$0.application(application, configurationForConnecting: connectingSceneSession, options: options)
			} ?? defaultSceneConfig(sceneSession: connectingSceneSession)
	}

	public func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
		for plugin in allPlugins.filter(as: ApplicationSceneObserver.self) {
			plugin.application(application, didDiscardSceneSessions: sceneSessions)
		}
	}

	// MARK: - Environment Changes

	public func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication) {
		for plugin in allPlugins.filter(as: ApplicationEnvironmentObserver.self) {
			plugin.applicationProtectedDataWillBecomeUnavailable(application)
		}
	}

	public func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication) {
		for plugin in allPlugins.filter(as: ApplicationEnvironmentObserver.self) {
			plugin.applicationProtectedDataDidBecomeAvailable(application)
		}
	}

	public func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
		for plugin in allPlugins.filter(as: ApplicationEnvironmentObserver.self) {
			plugin.applicationDidReceiveMemoryWarning(application)
		}
	}

	public func applicationSignificantTimeChange(_ application: UIApplication) {
		for plugin in allPlugins.filter(as: ApplicationEnvironmentObserver.self) {
			plugin.applicationSignificantTimeChange(application)
		}
	}

	// MARK: - State Restoration

	public func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
		allPlugins.filter(as: ApplicationStateRestorationObserver.self).contains {
			$0.application(application, shouldSaveSecureApplicationState: coder)
		}
	}

	public func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
		allPlugins.filter(as: ApplicationStateRestorationObserver.self).contains {
			$0.application(application, shouldRestoreSecureApplicationState: coder)
		}
	}

	public func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
		allPlugins.filter(as: ApplicationStateRestorationObserver.self).firstNonNil {
			$0.application(application, viewControllerWithRestorationIdentifierPath: identifierComponents, coder: coder)
		}
	}

	public func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
		for plugin in allPlugins.filter(as: ApplicationStateRestorationObserver.self) {
			plugin.application(application, willEncodeRestorableStateWith: coder)
		}
	}

	public func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
		for plugin in allPlugins.filter(as: ApplicationStateRestorationObserver.self) {
			plugin.application(application, didDecodeRestorableStateWith: coder)
		}
	}

	// MARK: - Remote Notifications

	public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		for plugin in allPlugins.filter(as: ApplicationRemoteNotificationObserver.self) {
			plugin.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
		}
	}

	public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		for plugin in allPlugins.filter(as: ApplicationRemoteNotificationObserver.self) {
			plugin.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
		}
	}

	public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
		await allPlugins.filter(as: ApplicationRemoteNotificationObserver.self).apply({
			await $0.application(application, didReceiveRemoteNotification: userInfo)
		}, then: { results in
			await results.min { lhs, rhs in
				lhs.rawValue < rhs.rawValue
			} ?? .noData
		})
	}

	// MARK: - Extensions

	public func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String) async {
		await allPlugins.filter(as: ApplicationExtensionObserver.self).apply({
			await $0.application(application, handleEventsForBackgroundURLSession: identifier)
		}, then: { _ in
		})
	}

	// swiftlint:disable:next discouraged_optional_collection
	public func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]?) async -> [AnyHashable: Any]? {
		await allPlugins.filter(as: ApplicationExtensionObserver.self).apply({
			await $0.application(application, handleWatchKitExtensionRequest: userInfo ?? [:])
		}, then: { results in
			await results.reduce(into: [:]) { initial, next in
				for (key, value) in next ?? [:] {
					initial[key] = value
				}
			}
		})
	}

	public func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
		for plugin in allPlugins.filter(as: ApplicationExtensionObserver.self) {
			plugin.applicationShouldRequestHealthAuthorization(application)
		}
	}

	public func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any? {
		allPlugins.filter(as: ApplicationExtensionObserver.self).firstNonNil {
			$0.application(application, handlerFor: intent)
		}
	}

	public func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
		allPlugins.filter(as: ApplicationExtensionObserver.self).allSatisfy {
			$0.application(application, shouldAllowExtensionPointIdentifier: extensionPointIdentifier)
		}
	}

	public func applicationShouldAutomaticallyLocalizeKeyCommands(_ application: UIApplication) -> Bool {
		allPlugins.filter(as: ApplicationExtensionObserver.self).allSatisfy {
			$0.applicationShouldAutomaticallyLocalizeKeyCommands(application)
		}
	}

	// MARK: - Window Info

	@available(iOS, deprecated: 27.0, message: "Use SceneWindowInfoObserver.supportedInterfaceOrientations(for:) instead")
	public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		allPlugins.filter(as: ApplicationWindowInfoObserver.self).firstNonNil {
			$0.application(application, supportedInterfaceOrientationsFor: window)
		} ?? .orientationsFromInfoPlist
	}
}

private extension AppDelegate {
	func defaultSceneConfig(sceneSession: UISceneSession) -> UISceneConfiguration {
		let config = sceneSession.configuration ?? .init(name: nil, sessionRole: sceneSession.role)
		config.delegateClass = config.delegateClass ?? SceneDelegateType.self
		return config
	}
}
