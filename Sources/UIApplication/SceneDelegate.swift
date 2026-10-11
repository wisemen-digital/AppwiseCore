//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CloudKit
import UIKit

/// An implementation of the scene delegate, that automatically integrates with scene plugins.
open class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	/// The shared scene delegate for the active scene.
	@available(iOSApplicationExtension, unavailable)
	public static var active: SceneDelegate? {
		UIApplication.shared.connectedScenes
			.first { $0.activationState == .foregroundActive }?
			.delegate as? SceneDelegate
	}

	/// The list of scene plugins, empty by default
	open var plugins: [SceneDelegatePlugin] {
		[]
	}

	/// Internal plugins that are automatically added
	private lazy var internalPlugins: [SceneDelegatePlugin] = [
	]

	/// All plugins combined (user plugins + internal plugins)
	private lazy var allPlugins: [SceneDelegatePlugin] = self.plugins + self.internalPlugins

	/// The main window for this scene
	public var window: UIWindow?

	// MARK: - Scene Lifecycle

	public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		for plugin in allPlugins.filter(as: SceneLifecycleObserver.self) {
			plugin.scene(scene, willConnectTo: session, options: connectionOptions)
		}
	}

	public func sceneDidDisconnect(_ scene: UIScene) {
		for plugin in allPlugins.filter(as: SceneLifecycleObserver.self) {
			plugin.sceneDidDisconnect(scene)
		}
	}

	public func sceneWillEnterForeground(_ scene: UIScene) {
		for plugin in allPlugins.filter(as: SceneLifecycleObserver.self) {
			plugin.sceneWillEnterForeground(scene)
		}
	}

	public func sceneDidBecomeActive(_ scene: UIScene) {
		for plugin in allPlugins.filter(as: SceneLifecycleObserver.self) {
			plugin.sceneDidBecomeActive(scene)
		}
	}

	public func sceneWillResignActive(_ scene: UIScene) {
		for plugin in allPlugins.filter(as: SceneLifecycleObserver.self) {
			plugin.sceneWillResignActive(scene)
		}
	}

	public func sceneDidEnterBackground(_ scene: UIScene) {
		for plugin in allPlugins.filter(as: SceneLifecycleObserver.self) {
			plugin.sceneDidEnterBackground(scene)
		}
	}

	// MARK: - Actions

	public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
		for plugin in allPlugins.filter(as: SceneActionObserver.self) {
			plugin.scene(scene, openURLContexts: URLContexts)
		}
	}

	public func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
		for plugin in allPlugins.filter(as: SceneActionObserver.self) {
			plugin.scene(scene, willContinueUserActivityWithType: userActivityType)
		}
	}

	public func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
		for plugin in allPlugins.filter(as: SceneActionObserver.self) {
			_ = plugin.scene(scene, continue: userActivity)
		}
	}

	public func scene(_ scene: UIScene, didFailToContinueUserActivityWithType userActivityType: String, error: any Error) {
		for plugin in allPlugins.filter(as: SceneActionObserver.self) {
			plugin.scene(scene, didFailToContinueUserActivityWithType: userActivityType, error: error)
		}
	}

	public func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        await allPlugins.filter(as: SceneActionObserver.self).apply({
			await $0.windowScene(windowScene, performActionFor: shortcutItem)
		}, then: { results in
			await results.allSatisfy(\.self)
		})
	}

	public func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
		for plugin in allPlugins.filter(as: SceneActionObserver.self) {
			plugin.windowScene(windowScene, userDidAcceptCloudKitShareWith: cloudKitShareMetadata)
		}
	}

	// MARK: - State Restoration

	public func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
		allPlugins.filter(as: SceneStateRestorationObserver.self).firstNonNil {
			$0.stateRestorationActivity(for: scene)
		}
	}

	public func scene(_ scene: UIScene, restoreInteractionStateWith stateRestorationActivity: NSUserActivity) {
		for plugin in allPlugins.filter(as: SceneStateRestorationObserver.self) {
			plugin.scene(scene, restoreInteractionStateWith: stateRestorationActivity)
		}
	}

	public func scene(_ scene: UIScene, didUpdate userActivity: NSUserActivity) {
		for plugin in allPlugins.filter(as: SceneStateRestorationObserver.self) {
			plugin.scene(scene, didUpdate: userActivity)
		}
	}

	// MARK: - Window Info

	@available(iOS, deprecated: 26.0, message: "Use windowScene(_: didUpdateEffectiveGeometry:) to be notified of the scene's geometry changes, or use traits whose values are inherited from the scene via the traitCollection of views and view controllers instead.")
	public func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: any UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
		for plugin in allPlugins.filter(as: SceneWindowInfoObserver.self) {
			plugin.windowScene(windowScene, didUpdate: previousCoordinateSpace, interfaceOrientation: previousInterfaceOrientation, traitCollection: previousTraitCollection)
		}
	}

	@available(iOS 26.0, *)
	public func windowScene(_ windowScene: UIWindowScene, didUpdateEffectiveGeometry previousEffectiveGeometry: UIWindowScene.Geometry) {
		for plugin in allPlugins.filter(as: SceneWindowInfoObserver.self) {
			plugin.windowScene(windowScene, didUpdateEffectiveGeometry: previousEffectiveGeometry)
		}
	}

	@available(iOS 27.0, *)
	public func supportedInterfaceOrientations(for windowScene: UIWindowScene) -> UIInterfaceOrientationMask {
		allPlugins
			.filter(as: SceneWindowInfoObserver.self)
			.firstNonNil { $0.supportedInterfaceOrientations(for: windowScene) } ?? .all
	}

	@available(iOS 26.0, *)
	public func preferredWindowingControlStyle(for windowScene: UIWindowScene) -> UIWindowScene.WindowingControlStyle {
		allPlugins
			.filter(as: SceneWindowInfoObserver.self)
			.firstNonNil { $0.preferredWindowingControlStyle(for: windowScene) } ?? .automatic
	}
}
