//
// AppwiseCore
// Copyright © 2024 Appwise
//

import CoreData

public struct StoreConfiguration {
	public let description: NSPersistentStoreDescription

	public init(description: NSPersistentStoreDescription) {
		self.description = description
	}
}
