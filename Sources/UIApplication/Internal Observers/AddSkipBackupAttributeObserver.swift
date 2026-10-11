//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CocoaLumberjack
import UIKit

/// Internal class for adding a "skip backup" attribute to the application support directory.
struct AddSkipBackupAttributeObserver: ApplicationLifecycleObserver {
	func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]) -> Bool {
		DispatchQueue.global(qos: .background).async {
			addSkipBackupAttributeToAppSupportDirectory()
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
