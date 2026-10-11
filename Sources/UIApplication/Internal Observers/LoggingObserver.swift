//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CocoaLumberjack

/// Internal class for initializing the logging framework
struct LoggingObserver: ApplicationLifecycleObserver {
	func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]) -> Bool {
		DDLog.add(DDOSLogger.sharedInstance)
		DDLog.add(SentryLogger.shared)

		return true
	}
}
