//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CloudKit
import UIKit

/// Observe scene state restoration changes and events
@MainActor
public protocol SceneStateRestorationObserver: SceneDelegatePlugin {
	func stateRestorationActivity(for scene: UIScene) -> NSUserActivity?
	func scene(_ scene: UIScene, restoreInteractionStateWith stateRestorationActivity: NSUserActivity)
	func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity)
}

public extension SceneStateRestorationObserver {
	func stateRestorationActivity(for _: UIScene) -> NSUserActivity? {
		nil
	}

	func scene(_: UIScene, restoreInteractionStateWith _: NSUserActivity) {
	}

	func scene(_: UIScene, didUpdate _: NSUserActivity) {
	}
}
