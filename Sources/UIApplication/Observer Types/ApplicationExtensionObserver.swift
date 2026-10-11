//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import Intents
import UIKit

/// Observe application extension changes or events, such as background downloads, WatchKit & other
/// …Kit integrations, and more.
@MainActor
public protocol ApplicationExtensionObserver: ApplicationDelegatePlugin {
	func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String) async
	func application(_ application: UIApplication, handleWatchKitExtensionRequest userInfo: [AnyHashable: Any]) async -> [AnyHashable: Any]
	func applicationShouldRequestHealthAuthorization(_ application: UIApplication)
	func application(_ application: UIApplication, handlerFor intent: INIntent) -> Any?
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask?
	func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool
	func applicationShouldAutomaticallyLocalizeKeyCommands(_ application: UIApplication) -> Bool
}

public extension ApplicationExtensionObserver {
	func application(_: UIApplication, handleEventsForBackgroundURLSession _: String) {
	}

	func application(_: UIApplication, handleWatchKitExtensionRequest _: [AnyHashable: Any]) -> [AnyHashable: Any] {
		[:]
	}

	func applicationShouldRequestHealthAuthorization(_: UIApplication) {
	}

	func application(_: UIApplication, handlerFor _: INIntent) -> Any? {
		nil
	}

	func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask? {
		nil
	}

	func application(_: UIApplication, shouldAllowExtensionPointIdentifier _: UIApplication.ExtensionPointIdentifier) -> Bool {
		true
	}

	func applicationShouldAutomaticallyLocalizeKeyCommands(_: UIApplication) -> Bool {
		true
	}
}
