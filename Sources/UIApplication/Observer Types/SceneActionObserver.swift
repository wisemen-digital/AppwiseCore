//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CloudKit
import UIKit

/// Observe scene action changes and events
@MainActor
public protocol SceneActionObserver: SceneDelegatePlugin {
	func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)
	func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String)
	func scene(_ scene: UIScene, continue userActivity: NSUserActivity)
	func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: any Error)
	func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool
	func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata)
}

public extension SceneActionObserver {
	func scene(_: UIScene, openURLContexts _: Set<UIOpenURLContext>) {
	}

	func scene(_: UIScene, willContinueUserActivityWithType _: String) {
	}

	func scene(_: UIScene, continue _: NSUserActivity) {
	}

	func scene(_: UIScene, didFailToContinueUserActivityWithType _: String, error _: any Error) {
	}

	func windowScene(_: UIWindowScene, performActionFor _: UIApplicationShortcutItem) -> Bool {
		true
	}

	func windowScene(_: UIWindowScene, userDidAcceptCloudKitShareWith _: CKShare.Metadata) {
	}
}
