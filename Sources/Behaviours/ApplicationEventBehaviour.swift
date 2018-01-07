//
//  ApplicationEventBehavior.swift
//  AppwiseCore
//
//  Created by Tom Knapen on 23/12/2016.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation

/// Behaviour for listening to application events such as will enter background/foreground.
public final class ApplicationEventBehavior: ViewControllerLifeCycleBehaviour {
	private let willEnterForeground: (() -> Void)?
	private let willEnterBackground: (() -> Void)?

	/// Creates a new instance with the specified foreground and background closures.
	///
	/// - parameter foreground: Closure to execute when the application enters the foreground.
	/// - parameter background: Closure to execute when the application enters the background.
	///
	/// - returns: The new behaviour instance.
	public init(foreground: (() -> Void)? = nil, background: (() -> Void)? = nil) {
		willEnterForeground = foreground
		willEnterBackground = background

		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: .UIApplicationWillResignActive, object: nil)
	}

	@objc
	private func applicationWillEnterForeground(_ sender: Notification) {
		willEnterForeground?()
	}

	@objc
	private func applicationWillResignActive(_ sender: Notification) {
		willEnterBackground?()
	}
}
