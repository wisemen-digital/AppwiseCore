//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

/// Observe application environment changes and events
@MainActor
public protocol ApplicationEnvironmentObserver: ApplicationDelegatePlugin {
	func applicationProtectedDataWillBecomeUnavailable(_ application: UIApplication)
	func applicationProtectedDataDidBecomeAvailable(_ application: UIApplication)
	func applicationDidReceiveMemoryWarning(_ application: UIApplication)
	func applicationSignificantTimeChange(_ application: UIApplication)
}

public extension ApplicationEnvironmentObserver {
	func applicationProtectedDataWillBecomeUnavailable(_: UIApplication) {
	}

	func applicationProtectedDataDidBecomeAvailable(_: UIApplication) {
	}

	func applicationDidReceiveMemoryWarning(_: UIApplication) {
	}

	func applicationSignificantTimeChange(_: UIApplication) {
	}
}
