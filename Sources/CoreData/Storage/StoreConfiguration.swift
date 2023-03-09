//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public struct StoreConfiguration {
	public let description: NSPersistentStoreDescription

	public init(description: NSPersistentStoreDescription) {
		self.description = description
	}
}
