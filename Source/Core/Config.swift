//
//  Config.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Foundation
import CocoaLumberjack

public typealias Version = String

public protocol Config {
	static var shared: Self { get }

	func initialize()
	func teardown()
	func handleUpdate(from old: Version, to new: Version)
}

public extension Config {
	func initialize() {
	}

	func teardown() {
	}

	func handleUpdate(from old: Version, to new: Version) {
	}
}

// MARK: - Application lifetime

public extension Config {
	final func setupApplication() {
		// if needed, reset app and exit early. At the end of reset, setup is
		// called again
		guard !Settings.shared.shouldReset else {
			resetApplication()
			return
		}

		// load default settings
		Settings.shared.load(with: self)

		// initialize core data
		db?.perform(NSSelectorFromString("initialize"))

		// user initialize
		initialize()
	}

	final func resetApplication() {
		// reset defaults
		Settings.shared.reset()

		// delete core data store
		db?.perform(NSSelectorFromString("reset"))

		// user teardown
		teardown()

		// re-setup application
		setupApplication()
	}
	
	private var db: NSObject? {
		guard let type = NSClassFromString("AppwiseCore.DB") as? NSObjectProtocol else { return nil }
		return type.perform(NSSelectorFromString("shared")).takeUnretainedValue() as? NSObject
	}
}

// MARK: - Other

public extension Config {
	var appName: String {
		return Bundle.main.infoDictionary?["CFBundleDisplayName"] as! String
	}

	var appVersion: Version {
		return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
	}

	var appBuild: String {
		return Bundle.main.infoDictionary?["CFBundleVersion"] as! String
	}
}
