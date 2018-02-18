//
//  FabricApplicationService.swift
//  Example
//
//  Created by David Jennes on 04/12/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import AppwiseCore
import Crashlytics
import CrashlyticsRecorder
import Fabric

final class FabricApplicationService: NSObject, ApplicationService {
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
		Fabric.with([Crashlytics()])
		_ = CrashlyticsRecorder.createSharedInstance(crashlytics: Crashlytics.sharedInstance())
		_ = AnswersRecorder.createSharedInstance(answers: Answers.self)

		return true
	}
}

// MARK: - Conform Crashlytics & Fabric to recorder protocol

extension Crashlytics: CrashlyticsProtocol {
	public func log(_ format: String, args: CVaListPointer) {
		#if DEBUG
			CLSNSLogv(format, args)
		#else
			CLSLogv(format, args)
		#endif
	}
}

extension Answers: AnswersProtocol {
}
