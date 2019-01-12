//
//  MainThreadCheck.swift
//  Pods
//
//  Created by David Jennes on 23/09/16.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

internal extension DispatchQueue {
	fileprivate static let mainQueueKey = DispatchSpecificKey<()>()

	static func configureMainQueue() {
		main.setSpecific(key: mainQueueKey, value: ())
	}
}

public extension DispatchQueue {
	/// Easy and safe way of checking if the current queue is the main queue
	static var isMain: Bool {
		return getSpecific(key: mainQueueKey) != nil
	}

	/// Easy and safe way of checking if the current queue is the main queue
	var isMain: Bool {
		return getSpecific(key: DispatchQueue.mainQueueKey) != nil
	}
}
