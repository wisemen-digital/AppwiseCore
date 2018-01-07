//
//  AppDelegate.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import CocoaLumberjack
import UIKit

/// Internal class for adding a "skip backup" attribute to the application support directory.
final class AddSkipBackupAttributeApplicationService: NSObject, ApplicationService {
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		DispatchQueue.global(qos: .background).async { [weak self] in
			self?.addSkipBackupAttributeToAppSupportDirectory()
		}

		return true
	}

	private func addSkipBackupAttributeToAppSupportDirectory() {
		do {
			guard let supportDirectory = UIApplication.shared.supportDirectory else { return }
			let mgr = FileManager.default

			// create support directory if needed
			if (!mgr.fileExists(atPath: supportDirectory.path)) {
				try mgr.createDirectory(at: supportDirectory, withIntermediateDirectories: true, attributes: nil)
			}

			// add skip attribute
			try (supportDirectory as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
		} catch let error {
			DDLogError("Error excluding support directory from backup: \(error)")
		}
	}
}
