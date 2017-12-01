//
//  MainThreadCheck.swift
//  Pods
//
//  Created by David Jennes on 23/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import Foundation

internal extension DispatchQueue {
	fileprivate static let mainQueueKey = DispatchSpecificKey<()>()

	static func configureMainQueue() {
		main.setSpecific(key: mainQueueKey, value: ())
	}
}

public extension DispatchQueue {
	static var isMain: Bool {
		return getSpecific(key: mainQueueKey) != nil
	}

	var isMain: Bool {
		return getSpecific(key: DispatchQueue.mainQueueKey) != nil
	}
}
