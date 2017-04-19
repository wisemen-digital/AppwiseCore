//
//  CrashlyticsLogger.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CocoaLumberjack
import CrashlyticsRecorder

internal final class CrashlyticsLogger: DDAbstractLogger {
	static let shared = CrashlyticsLogger()

	override func log(message logMessage: DDLogMessage) {
		guard let recorder = CrashlyticsRecorder.sharedInstance else { return }
		let msg = logFormatter?.format(message: logMessage) ?? logMessage.message

		recorder.log(msg)
	}
}
