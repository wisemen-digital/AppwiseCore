//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import CoreData

public struct StoreConfiguration {
	public let description: NSPersistentStoreDescription

	public init(description: NSPersistentStoreDescription) {
		self.description = description
	}
}
