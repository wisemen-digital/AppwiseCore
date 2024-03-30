//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import CocoaLumberjack
import Sentry

/// Internal CocoaLumberjack logger to Sentry
final class SentryLogger: DDAbstractLogger {
	static let shared = SentryLogger()

	override func log(message logMessage: DDLogMessage) {
		guard let level = logMessage.level.sentryLevel else { return }

		SentrySDK.capture(message: logFormatter?.format(message: logMessage) ?? logMessage.message) { scope in
			scope.setLevel(level)
		}
	}
}

private extension DDLogLevel {
	var sentryLevel: SentryLevel? {
		switch self {
		case .debug: .debug
		case .info: .info
		case .warning: .warning
		case .error: .error
		default: nil
		}
	}
}
