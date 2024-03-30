//
// AppwiseCore
// Copyright © 2024 Wisemen
//

public protocol PushNotificationType {
	static var typeIdentifiers: [String] { get }

	init?(type: String, data: [AnyHashable: Any])

	var canShow: Bool { get }

	func handle()
	func open()
}

public extension PushNotificationType {
	func handle() {
	}

	var canShow: Bool {
		true
	}

	func open() {
	}
}

public enum PushNotification {
}
