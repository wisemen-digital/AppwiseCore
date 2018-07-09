//
//  Insertable+NSManagedObject.swift
//  Alamofire+CoreData
//
//  Created by Manuel García-Estañ on 6/10/16.
//  Copyright © 2016 ManueGE. All rights reserved.
//

import CoreData
import Foundation
import Groot

extension NSManagedObject: Insertable {
    public static func insert(from json: Any, in context: ImportContext) throws -> Self {
        guard let dictionary = json as? JSONDictionary else {
            throw InsertError.invalidJSON(json)
        }

        return try object(fromJSONDictionary: dictionary, inContext: context.moc)
    }
}

extension NSManagedObject: ManyInsertable {
    public static func insertMany(from json: Any, in context: ImportContext) throws -> [Any] {
        guard let array = json as? JSONArray else {
            throw InsertError.invalidJSON(json)
        }

        let entityName = context.moc.entityDescriptionForClass(self).name.require(hint: "Entity has no name")

        return try objects(withEntityName: entityName,
                           fromJSONArray: array,
                           inContext: context.moc)
    }
}

fileprivate extension NSManagedObjectContext {
    /// Return the `NSEntityDescription` for the given type in the receiver `NSManagedObjectContext`.
    /// If the entity can't be found, it will throw a fatalError
    ///
    /// - parameter aClass: The class to match with an entity
    ///
    /// - returns: The `NSEntityDescription`
    func entityDescriptionForClass(_ aClass: NSManagedObject.Type) -> NSEntityDescription {
        let entityName = NSStringFromClass(aClass)
        let model = (persistentStoreCoordinator?.managedObjectModel).require(hint: "No managed object model available")

        for entityDescription in model.entities where entityDescription.managedObjectClassName == entityName {
            return entityDescription
        }

        fatalError("Can't found a match for the class \(aClass) in the context \(self)")
    }
}
