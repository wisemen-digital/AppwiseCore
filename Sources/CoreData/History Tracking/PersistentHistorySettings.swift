//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Foundation

public final class PersistentHistorySettings {
	public static let defaultTimeToLive: TimeInterval = 7 * 24 * 60 * 60 // 7 days

	private let defaults: UserDefaults
	private let authors: [Author]
	private let timeToLive: TimeInterval

	public init?(suiteName: String, authors: [Author], timeToLive: TimeInterval = PersistentHistorySettings.defaultTimeToLive) {
		if let defaults = UserDefaults(suiteName: suiteName) {
			self.defaults = defaults
			self.authors = authors
			self.timeToLive = timeToLive
		} else {
			return nil
		}
	}
}

// MARK: - Last history

internal extension PersistentHistorySettings {
	var expiryDate: Date {
		Date().addingTimeInterval(-timeToLive)
	}

	func lastHistory(key: Key) -> Date? {
		date(for: prefixedKey(for: key))
	}

	func updateLastHistory(key: Key, date: Date?) {
		defaults.set(date, forKey: prefixedKey(for: key))
	}

	func oldestHistory(storeID: String) -> Date? {
		let prefix = prefixedStore(for: storeID)
		let managedKeys = authors.map { prefixedKey(for: Key(storeID: storeID, author: $0)) }
		let dates = managedKeys.compactMap { date(for: $0) }

		if dates.count == managedKeys.count {
			return dates.min()
		} else {
			return nil
		}
	}
}

// MARK: - Reset

internal extension PersistentHistorySettings {
	struct Key {
		let storeID: String
		let author: Author

		var identifier: String {
			"\(storeID)-\(author.name)"
		}
	}

	func reset(key: Key) {
		defaults.removeObject(forKey: prefixedKey(for: key))
	}

	func reset(storeID: String) {
		let managedKeys = authors.map { prefixedKey(for: Key(storeID: storeID, author: $0)) }
		managedKeys.forEach { defaults.removeObject(forKey: $0) }
	}
}

// MARK: - Helpers

private extension PersistentHistorySettings {
	static let commonPrefix = "persistent-history-tracking"

	func prefixedKey(for key: Key) -> String {
		"\(Self.commonPrefix):\(key.identifier)"
	}

	func prefixedStore(for storeID: String) -> String {
		"\(Self.commonPrefix):\(storeID)"
	}

	func date(for key: String) -> Date? {
		defaults.object(forKey: key) as? Date
	}
}
