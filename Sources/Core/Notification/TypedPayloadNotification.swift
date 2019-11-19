//
//  TypedNotification.swift
//  AppwiseCore
//
//  Created by David Jennes on 19/12/17.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

/// A protocol to define notifications that are sent around with our `NotificationCenter` extension functionality
/// and contain a payload.
public protocol TypedPayloadNotification: TypedNotification {
	/// The type must be defined a `Notification`.
	associatedtype Payload

	/// A payload to send in a notification. It is sent through `Notification`'s `userInfo` property.
	var payload: Payload { get }
}

private enum UserInfoKey {
	static let payload = "payload"
}

public extension TypedPayloadNotification {
	func generateNotification(object: Any? = nil) -> Notification {
		let info = [UserInfoKey.payload: payload]
		return Notification(name: Self.notificationName, object: object, userInfo: info)
	}
}

public extension Notification {
	/// This function allows you to pull a payload out of a `Notification`, with the result being
	/// typed to the defined `Payload` type.
	///
	/// - Parameter notificationType: The notificationType to retrieve the payload from.
	/// - Returns: The payload from the `TypedNotification`.
	func getPayload<T: TypedPayloadNotification>(for notificationType: T.Type) -> T.Payload? {
		return userInfo?[UserInfoKey.payload] as? T.Payload
	}
}
