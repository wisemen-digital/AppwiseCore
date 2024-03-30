//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import CocoaLumberjack

/// Internal class for initializing the logging framework
final class LoggingApplicationService: NSObject, ApplicationService {
	// swiftlint:disable:next discouraged_optional_collection
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		DDLog.add(DDOSLogger.sharedInstance)
		DDLog.add(SentryLogger.shared)

		return true
	}
}
