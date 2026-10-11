//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

/// Lifecycle observers are a way of distributing delegate implementations into smaller isolated
/// parts.
@MainActor
public protocol DelegatePlugin {}

/// Application delegate plugins are a way of distributing `UIApplicationDelegate` implementations
/// into smaller isolated parts.
@MainActor
public protocol ApplicationDelegatePlugin: DelegatePlugin {}

public extension ApplicationDelegatePlugin {
	/// The application window.
	@available(iOSApplicationExtension, unavailable)
	var window: UIWindow? {
		guard let delegateWindow = UIApplication.shared.delegate?.window else { return nil }
		return delegateWindow
	}
}

/// Scene delegate plugins are a way of distributing `UIWindowSceneDelegate` implementations into
/// smaller isolated parts.
@MainActor
public protocol SceneDelegatePlugin: DelegatePlugin {}

public extension SceneDelegatePlugin {
	/// The active window scene.
	@available(iOSApplicationExtension, unavailable)
	static var activeScene: UIWindowScene? {
		UIApplication.shared.connectedScenes
			.first { $0.activationState == .foregroundActive } as? UIWindowScene
	}
}

// MARK: - Helper methods

extension Sequence {
	func filter<P>(as _: P.Type) -> [P] {
		compactMap { ($0 as Any) as? P }
	}

	func firstNonNil<T>(
		_ operation: (Element) -> T?
	) -> T? {
		lazy.compactMap(operation).first
	}

	func apply<T, S>(
		_ operation: sending @escaping @isolated(any) (Element) async -> T?,
		then handler: (AsyncCompactMapSequence<TaskGroup<T?>, T>) async -> S
	) async -> S {
		await withTaskGroup(of: T?.self, returning: S.self) { group in
			for service in self {
				group.addTask {
					await operation(service)
				}
			}

			return await handler(group.compactMap(\.self))
		}
	}
}
