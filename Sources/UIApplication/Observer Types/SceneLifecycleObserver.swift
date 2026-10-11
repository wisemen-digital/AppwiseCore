//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CloudKit
import UIKit

/// Observe scene lifecycle changes and events
@MainActor
public protocol SceneLifecycleObserver: SceneDelegatePlugin {
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
	func sceneDidDisconnect(_ scene: UIScene)
	func sceneWillEnterForeground(_ scene: UIScene)
	func sceneDidBecomeActive(_ scene: UIScene)
	func sceneWillResignActive(_ scene: UIScene)
	func sceneDidEnterBackground(_ scene: UIScene)
}

public extension SceneLifecycleObserver {
	func scene(_: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
	}

	func sceneDidDisconnect(_: UIScene) {
	}

	func sceneWillEnterForeground(_: UIScene) {
	}

	func sceneDidBecomeActive(_: UIScene) {
	}

	func sceneWillResignActive(_: UIScene) {
	}

	func sceneDidEnterBackground(_: UIScene) {
	}
}
