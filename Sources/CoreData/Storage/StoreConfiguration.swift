//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public struct StoreConfiguration {
	public struct Migration {
		public let oldStore: NSPersistentStoreDescription

		public init(oldStore: NSPersistentStoreDescription) {
			self.oldStore = oldStore
		}
	}

	public let description: NSPersistentStoreDescription
	public let migration: Migration?

	public init(description: NSPersistentStoreDescription, migration: Migration? = nil) {
		self.description = description
		self.migration = migration
	}
}
