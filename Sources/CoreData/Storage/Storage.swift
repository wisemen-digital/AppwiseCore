//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData
import Then

public protocol Storage: Then {
	var author: Author? { get }
	var configuration: ModelConfiguration { get }
	var storeConfigurations: [StoreConfiguration] { get }
}

public extension Storage {
	var author: Author? {
		nil
	}
}

extension Storage {
	func createContainer() -> NSPersistentContainer {
		NSPersistentContainer(name: configuration.name, managedObjectModel: configuration.model).then {
			$0.persistentStoreDescriptions = storeConfigurations.map(\.description)
		}
	}

	func historySettings(for store: NSPersistentStore) -> PersistentHistorySettings? {
		storeConfigurations.first { $0.description.url == store.url }?.historySettings
	}
}
