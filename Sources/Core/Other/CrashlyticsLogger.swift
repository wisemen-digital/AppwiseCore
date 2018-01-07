//
//  CrashlyticsLogger.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CocoaLumberjack
import CrashlyticsRecorder

/// Internal CocoaLumberjack logger to Crashlytics
internal final class CrashlyticsLogger: DDAbstractLogger {
	static let shared = CrashlyticsLogger()

	override func log(message logMessage: DDLogMessage) {
		guard let recorder = CrashlyticsRecorder.sharedInstance else { return }

		// Disable formatting for now until CocoaLumberjack has better interop with Swift
		// https://github.com/CocoaLumberjack/CocoaLumberjack/issues/643
		let message = logMessage.message

		recorder.log(message)
	}
}
