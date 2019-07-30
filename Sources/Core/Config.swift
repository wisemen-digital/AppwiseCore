//
//  Config.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CocoaLumberjack
import Foundation

/// This protocol complements the `AppDelegate` class, and should be where you place all code
/// related to the configuration of your application.
public protocol Config {
	/// `Config`s are singletons.
	static var shared: Self { get }

	/// This method will be called on start-up, and after each reset when needed. Any and all
	/// additional setup code should go here.
	func initialize()

	/// This method will be called on start-up if the user turned on the "reset" toggle. You
	/// should provide additional reset instructions here if needed.
	func teardownForReset()

	/// On start-up, the config will check if the application's version differs from the previous
	/// run. If it does, it'll call this method to allow you to perform the necessary upgrade
	/// operations.
	///
	/// - parameter old: The old application version, from the previous run.
	/// - parameter new: The new (current) application version.
	func handleUpdate(from old: Version, to new: Version)
}

/// Default implementations.
public extension Config {
	func initialize() {
	}

	func teardownForReset() {
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
	/// This method will be called on start-up, and after each reset when needed. It will load
	/// the setings from the bundle, and initialize the database if needed.
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

	/// This method will be called on start-up if the user turned on the "reset" toggle. It will
	/// reset the settings, and the database (if needed), then it'll finally call the
	/// `setupApplication()` method.
	func resetApplication() {
		// reset defaults
		Settings.shared.reset()

		// delete core data store
		_ = db?.perform(DBProxy.reset)

		// user teardown
		teardownForReset()

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
	static let bundleDisplayName = "CFBundleDisplayName"
	static let bundleName = "CFBundleName"
	static let shortVersion = "CFBundleShortVersionString"
	static let version = "CFBundleVersion"
}

public extension Config {
	/// The name of the application, taken from the info dictionary.
	var appName: String {
		if let value = Bundle.main.infoDictionary?[InfoKeys.bundleDisplayName] as? String {
			return value
		} else if let value = Bundle.main.infoDictionary?[InfoKeys.bundleName] as? String {
			return value
		} else {
			return ""
		}
	}

	/// The version of the application, taken from the info dictionary.
	var appVersion: Version {
		return Bundle.main.infoDictionary?[InfoKeys.shortVersion]
			.flatMap { $0 as? String }
			.flatMap(Version.init(string:)) ?? Version(0, 0, 0)
	}

	/// The build version of the application, taken from the info dictionary.
	var appBuild: String {
		guard let value = Bundle.main.infoDictionary?[InfoKeys.version] as? String else { return "" }
		return value
	}
}
