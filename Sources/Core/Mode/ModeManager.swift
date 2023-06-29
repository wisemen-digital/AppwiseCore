//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Combine
import Foundation

final public actor ModeManager {
	@Published private(set) public var activeMode: Mode? {
		didSet { updatedAt = Date() }
	}

	private(set) public var updatedAt: Date?

	public init(activeMode: Mode? = nil) {
		self.activeMode = activeMode
	}

	public func update(mode: Mode?) async {
		activeMode = mode
	}
}
