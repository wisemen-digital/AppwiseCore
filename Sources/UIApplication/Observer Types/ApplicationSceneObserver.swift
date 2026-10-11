//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

/// Observe application scene changes and events
@MainActor
public protocol ApplicationSceneObserver: ApplicationDelegatePlugin {
	func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration?
	func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>)
}

public extension ApplicationSceneObserver {
	func application(_: UIApplication, configurationForConnecting _: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration? {
		nil
	}

	func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
	}
}
