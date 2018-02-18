//
//  User.swift
//  Example
//
//  Created by David Jennes on 18/02/2018.
//  Copyright © 2018 Appwise. All rights reserved.
//

import AppwiseCore
import CoreData

extension User {
	static var current: User? {
		return current(in: DB.main)
	}

	static func current(in moc: NSManagedObjectContext) -> User? {
		guard let id = Settings.shared.currentUserID else { return nil }
		return moc.object(with: id) as? User
	}
}
