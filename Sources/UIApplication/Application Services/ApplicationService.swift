//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import UIKit

// Credit to Fernando Martín Ortiz for the original implementation:
// https://github.com/fmo91/PluggableApplicationDelegate

/// Application services are a way of distributing `UIApplicationDelegate` implementations into
/// smaller isolated parts. Just implement whatever delegate calls you want and wrap it in a small
/// NSObject.
public protocol ApplicationService: UIApplicationDelegate {}

public extension ApplicationService {
	/// The application window.
	@available(iOSApplicationExtension, unavailable)
	var window: UIWindow? {
		guard let window = UIApplication.shared.delegate?.window else { return nil }
		return window
	}
}

extension Array where Element == ApplicationService {
	@discardableResult
	func apply<T, S>(_ work: (ApplicationService, @escaping (T) -> Void) -> S?, then handler: @escaping ([T]) -> Swift.Void) -> [S] {
		let dispatchGroup = DispatchGroup()
		var results: [T] = []
		var returns: [S] = []

		for service in self {
			dispatchGroup.enter()
			let returned = work(service) { result in
				results.append(result)
				dispatchGroup.leave()
			}
			if let returned {
				returns.append(returned)
			} else { // delegate doesn't impliment method
				dispatchGroup.leave()
			}
			if returned == nil {
			}
		}

		dispatchGroup.notify(queue: .main) {
			handler(results)
		}

		return returns
	}
}
