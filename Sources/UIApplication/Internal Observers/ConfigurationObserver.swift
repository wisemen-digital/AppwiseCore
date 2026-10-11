//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import Foundation
import UIKit

/// Internal class responsible for linking the app delegate with the Config.
struct ConfigurationObserver<ConfigType: Config>: ApplicationLifecycleObserver {
	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]) -> Bool {
		ConfigType.shared.setupApplication()

		return true
	}
}
