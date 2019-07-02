//
//  PushNotificationHandler.swift
//  AppwiseCore
//
//  Created by David Jennes on 31/03/2019.
//  Copyright © 2019 Appwise. All rights reserved.
//

public protocol PushNotificationType {
	static var typeIdentifiers: [String] { get }

	init?(type: String, data: [AnyHashable: Any])

	func handle()
	var canShow: Bool { get }
	func open()
}

public extension PushNotificationType {
	func handle() {
	}

	var canShow: Bool {
		return true
	}

	func open() {
	}
}

public enum PushNotification {
}
