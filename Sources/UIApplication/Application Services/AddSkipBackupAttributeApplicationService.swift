//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import CocoaLumberjackSwift
import UIKit

/// Internal class for adding a "skip backup" attribute to the application support directory.
final class AddSkipBackupAttributeApplicationService: NSObject, ApplicationService {
	// swiftlint:disable:next discouraged_optional_collection
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
		DispatchQueue.global(qos: .background).async { [weak self] in
			self?.addSkipBackupAttributeToAppSupportDirectory()
		}

		return true
	}

	private func addSkipBackupAttributeToAppSupportDirectory() {
		do {
			guard let supportDirectory = FileManager.default.supportDirectory else { return }
			let mgr = FileManager.default

			// create support directory if needed
			if !mgr.fileExists(atPath: supportDirectory.path) {
				try mgr.createDirectory(at: supportDirectory, withIntermediateDirectories: true, attributes: nil)
			}

			// add skip attribute
			// swiftlint:disable:next legacy_objc_type
			try (supportDirectory as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
		} catch {
			DDLogError("Error excluding support directory from backup: \(error)")
		}
	}
}
