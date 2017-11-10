//
//  ApplicationEventBehavior.swift
//  AppwiseCore
//
//  Created by Tom Knapen on 23/12/2016.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation

final class ApplicationEventBehavior: ViewControllerLifeCycleBehaviour {
	private let willEnterForeground: (() -> Void)?
	private let willEnterBackground: (() -> Void)?

	init(foreground: (() -> Void)? = nil, background: (() -> Void)? = nil) {
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
