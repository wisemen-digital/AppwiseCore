//
// AppwiseCore
// Copyright © 2021 Appwise
//

import CocoaLumberjack
import Sentry

/// Internal CocoaLumberjack logger to Sentry
internal final class SentryLogger: DDAbstractLogger {
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
		case .debug: return .debug
		case .info: return .info
		case .warning: return .warning
		case .error: return .error
		default: return nil
		}
	}
}
