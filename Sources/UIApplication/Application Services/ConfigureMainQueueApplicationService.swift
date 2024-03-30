//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Foundation
import UIKit

/// Internal class for configuring the main queue for checking later
final class ConfigureMainQueueApplicationService: NSObject, ApplicationService {
	// swiftlint:disable:next discouraged_optional_collection
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		DispatchQueue.configureMainQueue()

		return true
	}
}
