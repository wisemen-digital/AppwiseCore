//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CoreData

extension NSPersistentStore {
	var canTrackPersistentHistory: Bool {
		if #available(iOS 13, *) {
			return persistentTrackingEnabled && persistentRemoteNotificationsEnabled
		} else {
			return false
		}
	}
}

@available(iOS 13, *)
private extension NSPersistentStore {
	var persistentTrackingEnabled: Bool {
		options?[NSPersistentHistoryTrackingKey].flatMap { $0 as? NSNumber }?.boolValue ?? false
	}

	var persistentRemoteNotificationsEnabled: Bool {
		options?[NSPersistentStoreRemoteChangeNotificationPostOptionKey].flatMap { $0 as? NSNumber }?.boolValue ?? false
	}
}
