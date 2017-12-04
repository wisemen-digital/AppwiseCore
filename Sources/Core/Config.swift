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

private enum DBProxy {
	static let `class`: AnyClass? = NSClassFromString("AppwiseCore.DB")
	static let initialize = NSSelectorFromString("initialize")
	static let reset = NSSelectorFromString("reset")
	static let shared = NSSelectorFromString("shared")
}

public extension Config {
	func setupApplication() {
		// if needed, reset app and exit early. At the end of reset, setup is
		// called again
		guard !Settings.shared.shouldReset else {
			resetApplication()
			return
		}

		// load default settings
		Settings.shared.load(with: self)

		// initialize core data
		_ = db?.perform(DBProxy.initialize)

		// user initialize
		initialize()
	}

	func resetApplication() {
		// reset defaults
		Settings.shared.reset()

		// delete core data store
		_ = db?.perform(DBProxy.reset)

		// user teardown
		teardown()

		// re-setup application
		setupApplication()
	}
	
	private var db: NSObject? {
		guard let type = DBProxy.`class` as? NSObject.Type else { return nil }
		return type.perform(DBProxy.shared).takeUnretainedValue() as? NSObject
	}
}

// MARK: - Other

private enum InfoKeys {
	static let displayName = "CFBundleDisplayName"
	static let shortVersion = "CFBundleShortVersionString"
	static let version = "CFBundleVersionKey"
}

public extension Config {
	var appName: String {
		guard let value = Bundle.main.infoDictionary?[InfoKeys.displayName] as? String else { return "" }
		return value
	}

	var appVersion: Version {
		guard let value = Bundle.main.infoDictionary?[InfoKeys.shortVersion] as? String else { return "" }
		return value
	}

	var appBuild: String {
		guard let value = Bundle.main.infoDictionary?[InfoKeys.version] as? String else { return "" }
		return value
	}
}
