//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import CoreData

public struct SQLiteStorage: Storage {
	public let fileURL: URL
	public let configuration: ModelConfiguration

	public var migrateStoreAutomatically = true
	public var inferMappingModelAutomatically = true
	public var addStoreAsynchronously = true

	public var analyzeEnabled = false
	public var vacuumEnabled = false
	public var isReadOnly = false

	public var persistentHistoryTrackingEnabled = false
	// swiftlint:disable:next identifier_name
	public var persistentStoreRemoteNotificationsEnabled = false

	public var configurationName: String?

	public init(fileURL: URL, configuration: ModelConfiguration) {
		self.fileURL = fileURL
		self.configuration = configuration
	}

	public var storeConfigurations: [StoreConfiguration] {
		[
			StoreConfiguration(description: buildStoreDescription())
		]
	}
}

// MARK: - Quick creation

public extension SQLiteStorage {
	enum Constants {
		public static let defaultName = "db"
		public static let groupFolderName = "CoreData"
	}

	static var legacy: Storage {
		`default`().with {
			$0.addStoreAsynchronously = false
		}
	}

	static func `default`(bundle: Bundle = .main) -> SQLiteStorage {
		if let url = defaultFileURL(name: Constants.defaultName), let configuration = ModelConfiguration(name: Constants.defaultName, bundle: bundle) {
			SQLiteStorage(fileURL: url, configuration: configuration)
		} else {
			fatalError("Unable to load store")
		}
	}

	static func group(identifier: String, bundle: Bundle = .main) -> SQLiteStorage {
		if let url = groupFileURL(name: Constants.defaultName, groupIdentifier: identifier), let configuration = ModelConfiguration(name: Constants.defaultName, bundle: bundle) {
			SQLiteStorage(fileURL: url, configuration: configuration)
		} else {
			fatalError("Unable to load store")
		}
	}
}

// MARK: - Path helpers

public extension SQLiteStorage {
	private static let sqliteExtension = "sqlite"

	static func defaultFileURL(name: String) -> URL? {
		if let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
			directory.appendingPathComponent(name).appendingPathExtension(sqliteExtension)
		} else {
			nil
		}
	}

	static func groupFileURL(name: String, groupIdentifier: String) -> URL? {
		if let directory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) {
			directory.appendingPathComponent(Constants.groupFolderName).appendingPathComponent(name).appendingPathExtension(sqliteExtension)
		} else {
			nil
		}
	}
}

// MARK: - Actual store description creation

private extension SQLiteStorage {
	func buildStoreDescription() -> NSPersistentStoreDescription {
		NSPersistentStoreDescription().then {
			$0.url = fileURL
			$0.configuration = configurationName

			$0.shouldMigrateStoreAutomatically = migrateStoreAutomatically
			$0.shouldInferMappingModelAutomatically = inferMappingModelAutomatically
			$0.shouldAddStoreAsynchronously = addStoreAsynchronously

			// swiftlint:disable legacy_objc_type
			$0.setOption(analyzeEnabled as NSNumber, forKey: NSSQLiteAnalyzeOption)
			$0.setOption(vacuumEnabled as NSNumber, forKey: NSSQLiteManualVacuumOption)
			$0.setOption(isReadOnly as NSNumber, forKey: NSReadOnlyPersistentStoreOption)

			if #available(iOS 13.0, *) {
				$0.setOption(persistentHistoryTrackingEnabled as NSNumber, forKey: NSPersistentHistoryTrackingKey)
				$0.setOption(persistentStoreRemoteNotificationsEnabled as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
			}
			// swiftlint:enable legacy_objc_type
		}
	}
}
