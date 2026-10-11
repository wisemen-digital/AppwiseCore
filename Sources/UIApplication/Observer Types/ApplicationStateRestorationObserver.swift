//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

/// Observe application state restoration changes and events
@MainActor
public protocol ApplicationStateRestorationObserver: ApplicationDelegatePlugin {
	func application(_ application: UIApplication, shouldSaveSecureApplicationState coder: NSCoder) -> Bool
	func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool
	func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController?
	func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder)
	func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder)
}

public extension ApplicationStateRestorationObserver {
	func application(_: UIApplication, shouldSaveSecureApplicationState _: NSCoder) -> Bool {
		false
	}

	func application(_: UIApplication, shouldRestoreSecureApplicationState _: NSCoder) -> Bool {
		false
	}

	func application(_: UIApplication, viewControllerWithRestorationIdentifierPath _: [String], coder _: NSCoder) -> UIViewController? {
		nil
	}

	func application(_: UIApplication, willEncodeRestorableStateWith _: NSCoder) {
	}

	func application(_: UIApplication, didDecodeRestorableStateWith _: NSCoder) {
	}
}
