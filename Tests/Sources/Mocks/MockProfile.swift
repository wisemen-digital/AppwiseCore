//
// AppwiseCore
// Copyright © 2022 Appwise
//

import AppwiseCore
import CoreData
import Foundation

internal class MockProfile: NSManagedObject {
	internal class var entityName: String {
		return "MockProfile"
	}

	internal class func entity(in managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
		return NSEntityDescription.entity(forEntityName: entityName, in: managedObjectContext)
	}

	@nonobjc internal class func fetchRequest() -> NSFetchRequest<MockProfile> {
		return NSFetchRequest<MockProfile>(entityName: entityName)
	}

	@NSManaged internal dynamic var email: String?
	@NSManaged internal dynamic var firstName: String?
	@NSManaged internal dynamic var lastName: String?

	internal dynamic var id: MockProfile.ID {
		get {
			let key = "id"
			willAccessValue(forKey: key)
			defer { didAccessValue(forKey: key) }

			guard let value = primitiveValue(forKey: key) as? MockProfile.ID.RawValue,
				  let result = MockProfile.ID(rawValue: value) else {
				fatalError("Could not convert value for key '\(key)' to type 'User.ID'")
			}
			return result
		}
		set {
			let key = "id"
			willChangeValue(forKey: key)
			defer { didChangeValue(forKey: key) }

			setPrimitiveValue(newValue.rawValue, forKey: key)
		}
	}
}

extension MockProfile: Identifiable {
	typealias RawIdentifier = Int64
}
