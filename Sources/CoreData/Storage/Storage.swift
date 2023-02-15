//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData
import Then

public protocol Storage: Then {
	var configuration: ModelConfiguration { get }
	var storeConfigurations: [StoreConfiguration] { get }
}

extension Storage {
	func createContainer() -> NSPersistentContainer {
		NSPersistentContainer(name: configuration.name, managedObjectModel: configuration.model).then {
			$0.persistentStoreDescriptions = storeConfigurations.map(\.description)
		}
	}
}
