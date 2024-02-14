//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public struct HybridStorage: Storage {
	public let configuration: ModelConfiguration
	public let storeConfigurations: [StoreConfiguration]

	init(configuration: ModelConfiguration, storeConfigurations: [StoreConfiguration]) {
		self.configuration = configuration
		self.storeConfigurations = storeConfigurations
	}
}

// MARK: - Quick creation

public extension HybridStorage {
	enum Constants {
		public static let defaultName = "db"
		public static let memoryConfigurationName = "Memory"
		public static let persistentConfigurationName = "Persistent"
	}

	static func build(configuration: ModelConfiguration, storages: [Storage]) -> HybridStorage {
		HybridStorage(
			configuration: configuration,
			storeConfigurations: storages.map(\.storeConfigurations).flatMap { $0 }
		)
	}

	static func `default`(configuration: ModelConfiguration, persistentURL: URL) -> HybridStorage {
		var memoryStorage = InMemoryStorage(configuration: configuration)
		memoryStorage.configurationName = Constants.memoryConfigurationName

		var persistentStorage = SQLiteStorage(fileURL: persistentURL, configuration: configuration)
		persistentStorage.configurationName = Constants.persistentConfigurationName

		return build(configuration: configuration, storages: [persistentStorage, memoryStorage])
	}

	static func `default`(bundle: Bundle = .main) -> HybridStorage {
		if let configuration = ModelConfiguration(name: Constants.defaultName, bundle: bundle),
		   let url = SQLiteStorage.defaultFileURL(name: Constants.defaultName) {
			return `default`(configuration: configuration, persistentURL: url)
		} else {
			fatalError("Unable to load store")
		}
	}

	static func group(identifier: String, bundle: Bundle = .main) -> HybridStorage {
		if let configuration = ModelConfiguration(name: Constants.defaultName, bundle: bundle),
		   let url = SQLiteStorage.groupFileURL(name: Constants.defaultName, groupIdentifier: identifier) {
			return `default`(configuration: configuration, persistentURL: url)
		} else {
			fatalError("Unable to load store")
		}
	}
}
