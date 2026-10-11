//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

/// Observe application lifecycle changes and events
@MainActor
public protocol ApplicationLifecycleObserver: ApplicationDelegatePlugin {
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]) -> Bool
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]) -> Bool
	func applicationWillTerminate(_ application: UIApplication)
}

public extension ApplicationLifecycleObserver {
	func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]) -> Bool {
		true
	}

	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]) -> Bool {
		true
	}

	func applicationWillTerminate(_: UIApplication) {
	}
}
