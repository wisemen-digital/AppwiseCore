//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Foundation

public protocol Author {
	var name: String { get }
}

public enum ContextAuthor: Author {
	case view
	case background
	case custom(name: String)

	public var name: String {
		switch self {
		case .view: return "view"
		case .background: return "background"
		case .custom(let name): return name
		}
	}
}

public enum TargetAuthor: Author {
	case main
	case notificationService
	case share
	case widget
	case custom(name: String)

	public var name: String {
		switch self {
		case .main: return "main"
		case .notificationService: return "notification-service"
		case .share: return "share"
		case .widget: return "widget"
		case .custom(let name): return name
		}
	}
}
