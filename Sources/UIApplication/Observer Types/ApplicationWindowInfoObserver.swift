//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import Intents
import UIKit

/// Observe application window info changes and events
@MainActor
public protocol ApplicationWindowInfoObserver: ApplicationDelegatePlugin {
	@available(iOS, deprecated: 27.0, message: "Use SceneWindowInfoObserver.supportedInterfaceOrientations(for:) instead")
	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask?
}

public extension ApplicationWindowInfoObserver {
	func application(_: UIApplication, supportedInterfaceOrientationsFor _: UIWindow?) -> UIInterfaceOrientationMask? {
		nil
	}
}
