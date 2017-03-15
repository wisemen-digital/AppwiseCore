//
//  MainThreadCheck.swift
//  Pods
//
//  Created by David Jennes on 23/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Foundation

internal extension DispatchQueue {
	fileprivate static let mainQueueKey = DispatchSpecificKey<UnsafeMutablePointer<Void>>()
	fileprivate static let mainQueueValue = UnsafeMutablePointer<Void>.allocate(capacity: 1)

	static func configureMainQueue() {
		main.setSpecific(key: mainQueueKey, value: mainQueueValue)
	}
}

public extension DispatchQueue {
	static var isMain: Bool {
		return getSpecific(key: mainQueueKey) == mainQueueValue
	}

	var isMain: Bool {
		return getSpecific(key: DispatchQueue.mainQueueKey) == DispatchQueue.mainQueueValue
	}
}
