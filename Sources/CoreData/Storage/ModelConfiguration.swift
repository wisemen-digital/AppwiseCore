//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

public struct ModelConfiguration {
	public let name: String
	public let model: NSManagedObjectModel

	public init(name: String, model: NSManagedObjectModel) {
		self.name = name
		self.model = model
	}

	public init?(name: String, bundle: Bundle) {
		if let model = NSManagedObjectModel.mergedModel(from: [bundle]) {
			self.init(name: name, model: model)
		} else {
			return nil
		}
	}
}
