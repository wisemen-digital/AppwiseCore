//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Foundation
import UIKit

/// Internal class responsible for linking the app delegate with the Config.
final class ConfigurationApplicationService<ConfigType: Config>: NSObject, ApplicationService {
	func applicationDidFinishLaunching(_: UIApplication) {
		ConfigType.shared.setupApplication()
	}

	// swiftlint:disable:next discouraged_optional_collection
	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		ConfigType.shared.setupApplication()

		return true
	}
}
