//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import Foundation

extension DispatchQueue {
	fileprivate static let mainQueueKey = DispatchSpecificKey<Void>()

	static func configureMainQueue() {
		main.setSpecific(key: mainQueueKey, value: ())
	}
}

public extension DispatchQueue {
	/// Easy and safe way of checking if the current queue is the main queue
	static var isMain: Bool {
		getSpecific(key: mainQueueKey) != nil
	}

	/// Easy and safe way of checking if the current queue is the main queue
	var isMain: Bool {
		getSpecific(key: Self.mainQueueKey) != nil
	}
}
