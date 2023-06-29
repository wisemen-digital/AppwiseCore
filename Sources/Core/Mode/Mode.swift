//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import Foundation

public struct MaintenanceMetaData: ModeMetaData, Decodable {
	public let title: String?
	public let message: String?
	public let downUntil: Date?
	public let infoUrl: URL?
}

public struct Mode {
	public let identifier: String
	public let metaData: ModeMetaData?

	public init(identifier: String, metaData: ModeMetaData? = nil) {
		self.identifier = identifier
		self.metaData = metaData
	}

	public var isMaintenace: Bool {
		identifier == ModeIdentifier.maintenance.rawValue
	}
}

public protocol ModeMetaData { }

public enum ModeIdentifier: String {
	case maintenance
}
