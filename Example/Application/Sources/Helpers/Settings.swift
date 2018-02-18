//
//  Settings.swift
//  Example
//
//  Created by David Jennes on 18/05/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import AppwiseCore
import CoreData

extension Settings {
	private enum DefaultsKey: String {
		case currentUserID
	}

	var currentUserID: NSManagedObjectID? {
		get {
			guard let url = defaults.url(forKey: DefaultsKey.currentUserID.rawValue),
				let coordinator = DB.main.persistentStoreCoordinator else { return nil }
			return coordinator.managedObjectID(forURIRepresentation: url)
		}
		set {
			defaults.set(newValue?.uriRepresentation(), forKey: DefaultsKey.currentUserID.rawValue)
			defaults.synchronize()
		}
	}
}
