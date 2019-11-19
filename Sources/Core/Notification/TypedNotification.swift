//
//  TypedNotification.swift
//  AppwiseCore
//
//  Created by David Jennes on 19/12/17.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

// Credit to Joe Fabisevich for the original idea and implementation, which can be found here:
// https://github.com/mergesort/TypedNotifications
// Last check on 19 November 2017

/// A protocol to define notifications that are sent around with our `NotificationCenter` extension functionality.
public protocol TypedNotification {
	/// Generate a `Notification` object from this instance, with the correct name.
	///
	/// - parameter object: The sending object.
	/// - returns: A new `Notification` instance.
	func generateNotification(object: Any?) -> Notification
}

public extension TypedNotification {
	/// This function posts this typed notification.
	///
	/// - Parameters:
	///   - notificationCenter: The notification center to register with (default: .default)
	func post(notificationCenter: NotificationCenter = .default, object: Any? = nil) {
		let notification = generateNotification(object: object)
		notificationCenter.post(notification)
	}

	/// This function registers this type of typed notification.
	///
	/// - Parameters:
	///   - observer: An observer to use for calling the target selector.
	///   - selector: The selector to call the observer with.
	///   - object: The sender to register.
	///   - notificationCenter: The notification center to register with (default: .default)
	static func register(observer: Any, selector: Selector, object: Any? = nil, notificationCenter: NotificationCenter = .default) {
		let name = Self.notificationName
		notificationCenter.addObserver(observer, selector: selector, name: name, object: object)
	}

	/// This function unregisters the observer for this type of notification
	///
	/// - Parameters:
	///   - observer: The observer to unregister.
	///   - object: The sender to unregister.
	///   - notificationCenter: The notification center to unregister with (default: .default)
	static func unregister(observer: Any, object: Any? = nil, notificationCenter: NotificationCenter = .default) {
		let name = Self.notificationName
		notificationCenter.removeObserver(observer, name: name, object: object)
	}
}

extension TypedNotification {
	/// Generate a `Notification` object from this instance, with the correct name.
	///
	/// - parameter object: The sending object.
	/// - returns: A new `Notification` instance.
	public func generateNotification(object: Any? = nil) -> Notification {
		return Notification(name: Self.notificationName, object: object)
	}

	internal static var notificationName: Notification.Name {
		let name = String(describing: self)
		return Notification.Name(rawValue: name)
	}
}
