//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import Foundation
import UIKit

/// Internal class for configuring the main queue for checking later
struct ConfigureMainQueueObserver: ApplicationLifecycleObserver {
	func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]) -> Bool {
		DispatchQueue.configureMainQueue()

		return true
	}
}
