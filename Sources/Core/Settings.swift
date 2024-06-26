//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import CocoaLumberjack
import Foundation

/// This is a light layer over the UserDefaults framework, that'll load any settings you have
/// in a settings bundle, and perform version checks for the `Config`.
public struct Settings {
	fileprivate enum DefaultsKey: String {
		case reset = "reset_app"
		case resourceTimestamps
		case version
		case lastVersion
	}

	/// `Settings` is a singleton.
	public static var shared = Self()
	/// The underlying user defaults.
	public let defaults = UserDefaults.standard

	private init() {}

	mutating func load(with config: some Config) {
		// version check
		let new = config.appVersion
		if let old = lastVersion, old < new {
			config.handleUpdate(from: old, to: new)
		}
		version = "\(config.appVersion) (\(config.appBuild))"
		lastVersion = config.appVersion

		// try to load settings bundle
		// swiftlint:disable legacy_objc_type
		guard let bundle = Bundle.main.path(forResource: "Settings", ofType: "bundle") as NSString?,
		      let settings = NSDictionary(contentsOfFile: bundle.appendingPathComponent("Root.plist")),
		      let preferences = settings["PreferenceSpecifiers"] as? [[String: Any]] else {
			DDLogError("Could not find Settings.bundle")
			return
		}
		// swiftlint:enable legacy_objc_type

		// load defaults from settings bundle
		var data = [String: Any]()
		for specification in preferences {
			guard let key = specification["Key"] as? String,
			      defaults.object(forKey: key) == nil else { continue }
			data[key] = specification["DefaultValue"]
		}
		defaults.register(defaults: data)
	}

	func reset() {
		guard let identifier = Bundle.main.bundleIdentifier else { return }
		defaults.removePersistentDomain(forName: identifier)
	}

	var shouldReset: Bool {
		get {
			defaults.bool(forKey: DefaultsKey.reset.rawValue)
		}
		set {
			defaults.set(newValue, forKey: DefaultsKey.reset.rawValue)
		}
	}

	private var version: String? {
		get {
			defaults.string(forKey: DefaultsKey.version.rawValue)
		}
		set {
			defaults.set(newValue, forKey: DefaultsKey.version.rawValue)
		}
	}

	private var lastVersion: Version? {
		get {
			// fallback to readable version if needed
			let string = defaults.string(forKey: DefaultsKey.lastVersion.rawValue) ??
				version?.components(separatedBy: " ").first
			return string.flatMap(Version.init(string:))
		}
		set {
			defaults.set(newValue?.description ?? "", forKey: DefaultsKey.lastVersion.rawValue)
		}
	}
}

extension Settings {
	func key<R: Router>(router: R) -> String {
		"\(router.method)|\(R.baseURLString)|\(router.path)"
	}

	func timestamp(router: some Router) -> TimeInterval {
		guard let timestamps = defaults.dictionary(forKey: DefaultsKey.resourceTimestamps.rawValue) as? [String: Double] else {
			return 0
		}
		return timestamps[key(router: router)] ?? 0
	}

	func setTimestamp(_ timestamp: TimeInterval, router: some Router) {
		var timestamps = defaults.dictionary(forKey: DefaultsKey.resourceTimestamps.rawValue) as? [String: Double] ?? [String: Double]()

		timestamps[key(router: router)] = timestamp
		defaults.set(timestamps, forKey: DefaultsKey.resourceTimestamps.rawValue)
	}
}
