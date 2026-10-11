//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

/// Observe application remove notification changes and events
@MainActor
public protocol ApplicationRemoteNotificationObserver: ApplicationDelegatePlugin {
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error)
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult?
}

public extension ApplicationRemoteNotificationObserver {
	func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {
	}

	func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: any Error) {
	}

	func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any]) -> UIBackgroundFetchResult? {
		nil
	}
}
