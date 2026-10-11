//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CloudKit
import UIKit

/// Observe scene window info changes and events
@MainActor
public protocol SceneWindowInfoObserver: SceneDelegatePlugin {
	@available(iOS, deprecated: 26.0, message: "Use windowScene(_: didUpdateEffectiveGeometry:) to be notified of the scene's geometry changes, or use traits whose values are inherited from the scene via the traitCollection of views and view controllers instead.")
	func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: any UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection)

	@available(iOS 26.0, *)
	func windowScene(_ windowScene: UIWindowScene, didUpdateEffectiveGeometry previousEffectiveGeometry: UIWindowScene.Geometry)

	@available(iOS 27.0, *)
	func supportedInterfaceOrientations(for windowScene: UIWindowScene) -> UIInterfaceOrientationMask?

	@available(iOS 26.0, *)
	func preferredWindowingControlStyle(for windowScene: UIWindowScene) -> UIWindowScene.WindowingControlStyle?
}

public extension SceneWindowInfoObserver {
	func windowScene(_: UIWindowScene, didUpdate _: any UICoordinateSpace, interfaceOrientation _: UIInterfaceOrientation, traitCollection _: UITraitCollection) {
	}

	@available(iOS 26.0, *)
	func windowScene(_: UIWindowScene, didUpdateEffectiveGeometry _: UIWindowScene.Geometry) {
	}

	@available(iOS 27.0, *)
	func supportedInterfaceOrientations(for _: UIWindowScene) -> UIInterfaceOrientationMask? {
		nil
	}

	@available(iOS 26.0, *)
	func preferredWindowingControlStyle(for _: UIWindowScene) -> UIWindowScene.WindowingControlStyle? {
		nil
	}
}
