//
//  Settings.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Foundation

/// This is a light layer over the UserDefaults framework, that'll load any settings you have
/// in a settings bundle, and perform version checks for the `Config`.
public struct Settings {
	fileprivate enum DefaultsKey: String {
		case reset = "reset_app"
		case resourceTimestamps
		case version
	}

	/// `Settings` is a singleton.
	public static var shared = Settings()
	/// The underlying user defaults.
	public let defaults = UserDefaults.standard
	private init() {}

	internal mutating func load<C: Config>(with config: C) {
		// version check
		let old = version?.components(separatedBy: " ").first
		let new = config.appVersion
		if let old = old,
			old.compare(new, options: .numeric) == .orderedAscending {
			config.handleUpdate(from: old, to: new)
		}
		version = "\(config.appVersion) (\(config.appBuild))"

		// try to load settings bundle
		guard let bundle = Bundle.main.path(forResource: "Settings", ofType: "bundle") as NSString?,
			let settings = NSDictionary(contentsOfFile: bundle.appendingPathComponent("Root.plist")),
			let preferences = settings["PreferenceSpecifiers"] as? [[String: Any]] else {
				//DDLogError("Could not find Settings.bundle")
				return
		}

		// load defaults from settings bundle
		var data = [String: Any]()
		for specification in preferences {
			guard let key = specification["Key"] as? String,
				defaults.object(forKey: key) == nil else { continue }
			data[key] = specification["DefaultValue"]
		}
		defaults.register(defaults: data)
		defaults.synchronize()
	}

	internal func reset() {
		guard let identifier = Bundle.main.bundleIdentifier else { return }
		defaults.removePersistentDomain(forName: identifier)
	}

	internal var shouldReset: Bool {
		get {
			return defaults.bool(forKey: DefaultsKey.reset.rawValue)
		}
		set {
			defaults.set(false, forKey: DefaultsKey.reset.rawValue)
			defaults.synchronize()
		}
	}

	private var version: Version? {
		get {
			return defaults.string(forKey: DefaultsKey.version.rawValue)
		}
		set {
			defaults.set(newValue, forKey: DefaultsKey.version.rawValue)
			defaults.synchronize()
		}
	}
}

extension Settings {
	func key<R: Router>(router: R) -> String {
		return "\(router.method)|\(R.baseURLString)|\(router.path)"
	}

	func timestamp<R: Router>(router: R) -> TimeInterval {
		guard let timestamps = defaults.dictionary(forKey: DefaultsKey.resourceTimestamps.rawValue) as? [String: Double] else {
			return 0
		}
		return timestamps[key(router: router)] ?? 0
	}

	func setTimestamp<R: Router>(_ timestamp: TimeInterval, router: R) {
		var timestamps = defaults.dictionary(forKey: DefaultsKey.resourceTimestamps.rawValue) as? [String: Double] ?? [String: Double]()

		timestamps[key(router: router)] = timestamp
		defaults.set(timestamps, forKey: DefaultsKey.resourceTimestamps.rawValue)
		defaults.synchronize()
	}
}
