//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public struct InMemoryStorage: Storage {
	public let configuration: ModelConfiguration

	public var configurationName: String?

	public init(configuration: ModelConfiguration) {
		self.configuration = configuration
	}

	public var storeConfigurations: [StoreConfiguration] {
		[
			StoreConfiguration(description: buildStoreDescription())
		]
	}
}

// MARK: - Actual store description creation

private extension InMemoryStorage {
	func buildStoreDescription() -> NSPersistentStoreDescription {
		NSPersistentStoreDescription().then {
			$0.url = URL(fileURLWithPath: "/dev/null")
			$0.configuration = configurationName
		}
	}
}
