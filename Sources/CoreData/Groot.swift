//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import CoreData
import Foundation

typealias JSONDictionary = [String: Any]
typealias JSONArray = [JSONDictionary]

func object<T>(fromJSONDictionary: JSONDictionary, inContext: NSManagedObjectContext) throws -> T where T: NSFetchRequestResult {
	fatalError("object(fromJSONDictionary:inContext:) is not available")
}

func objects(withEntityName: String, fromJSONArray: JSONArray, inContext: NSManagedObjectContext) throws -> [Any] {
	fatalError("objects(withEntityName:fromJSONArray:inContext:) is not available")
}
