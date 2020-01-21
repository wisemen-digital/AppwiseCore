//
//  SentryLogger.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CocoaLumberjack
import Sentry

/// Internal CocoaLumberjack logger to Sentry
internal final class SentryLogger: DDAbstractLogger {
	static let shared = SentryLogger()

	override func log(message logMessage: DDLogMessage) {
		guard let client = Sentry.Client.shared,
			let severity = logMessage.level.severity else { return }

		let event = Event(level: severity)
		event.message = logFormatter?.format(message: logMessage) ?? logMessage.message
		client.send(event: event)
	}
}

private extension DDLogLevel {
	var severity: SentrySeverity? {
		switch self {
		case .debug: return .debug
		case .info: return .info
		case .warning: return .warning
		case .error: return .error
		default: return nil
		}
	}
}
