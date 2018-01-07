//
//  TypedNotification.swift
//  AppwiseCore
//
//  Created by David Jennes on 19/12/17.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation

// Credit to Joe Fabisevich for the original idea and implementation, which can be found here:
// https://github.com/mergesort/TypedNotifications

/// A protocol to define notifications that are sent around with our `NotificationCenter` extension functionality.
public protocol TypedNotification {
	/// Generate a `Notification` object from this instance, with the correct name.
	///
	/// - returns: A new `Notification` instance.
	func generateNotification() -> Notification
}

public extension TypedNotification {
	/// This function posts this typed notification.
	///
	/// - Parameters:
	///   - notificationCenter: The notification center to register with (default: .default)
	func post(notificationCenter: NotificationCenter = .default) {
		let notification = generateNotification()
		notificationCenter.post(notification)
	}

	/// This function registers this type of typed notification.
	///
	/// - Parameters:
	///   - observer: An observer to use for calling the target selector.
	///   - selector: The selector to call the observer with.
	///   - notificationCenter: The notification center to register with (default: .default)
	static func register(observer: Any, selector: Selector, notificationCenter: NotificationCenter = .default) {
		let name = Self.notificationName
		notificationCenter.addObserver(observer, selector: selector, name: name, object: nil)
	}
}

extension TypedNotification {
	/// Generate a `Notification` object from this instance, with the correct name.
	///
	/// - returns: A new `Notification` instance.
	public func generateNotification() -> Notification {
		return Notification(name: Self.notificationName)
	}

	internal static var notificationName: Notification.Name {
		let name = String(describing: self)
		return Notification.Name(rawValue: name)
	}
}
