//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import CocoaLumberjack
import Sentry

/// Internal CocoaLumberjack logger to Sentry
public final class SentryLogger: DDAbstractLogger {
	public static let shared = SentryLogger()

	public override func log(message logMessage: DDLogMessage) {
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
