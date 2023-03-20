//
//  MaintenanceMode.swift
//  AppwiseCore
//
//  Created by Tom Knapen on 16/03/2023.
//

import Alamofire
import Foundation

public protocol MaintenanceModeChecker {
	/// Check maintenance mode status.
	///
	/// There are no guarantees on which thread this code will execute. You *must* call `handler` at some point.
	func checkMaintenanceMode(then handler: @escaping (_ enabled: Bool?) -> Void)
}

public protocol MaintenanceModeResponseChecker {
	/// Check response for maintenance mode status.
	static func inMaintenanceMode<T>(response: DataResponse<T, AFError>) -> Bool
}

public enum MaintenanceMode {
	/// This notification gets posted whenever the app enters maintenance mode.
	public struct EnterMaintenanceMode: TypedPayloadNotification {
		public let payload: Manager
	}
	/// This notification gets posted whenever the app exits maintenance mode.
	public struct ExitMaintenanceMode: TypedPayloadNotification {
		public let payload: Manager
	}
	/// This notification gets posted whenever the maintenance mode did change.
	public struct MaintenanceModeDidChange: TypedPayloadNotification {
		public let payload: Manager
	}

	public final class Manager {
		private let serialQueue = DispatchQueue(label: "maintenance-mode-manager-queue")
		private var checker: MaintenanceModeChecker?
		private var isChecking: Bool = false

		/// Returns `true` if maintenance mode is currently enabled.
		private(set) public var isEnabled: Bool = false

		public init(isEnabled: Bool = false) {
			self.isEnabled = isEnabled
		}

		public func attach(checker: MaintenanceModeChecker) {
			self.checker = checker
		}

		public func check() {
			serialQueue.async { [weak self] in
				guard let self = self, !self.isChecking else { return }

				if let checker = self.checker {
					self.isChecking = true
					checker.checkMaintenanceMode { [weak self] enabled in
						self?.serialQueue.async {
							defer { self?.isChecking = false }

							if let enabled = enabled {
								self?.setMaintenanceModeEnabled(enabled)
							}
						}
					}
				}
			}
		}

		/// Set whether or not maintenance mode is currently enabled. If maintenance mode has changed, this will send the appropriate local notifications.
		///
		/// If `force` is true, local notifications will be sent regardless of the current maintenance mode.
		public func setMaintenanceModeEnabled(_ enabled: Bool, force: Bool = false) {
			guard enabled != isEnabled || force else { return }

			isEnabled = enabled

			DispatchQueue.main.async {
				if enabled {
					EnterMaintenanceMode(payload: self).post()
				} else {
					ExitMaintenanceMode(payload: self).post()
				}

				MaintenanceModeDidChange(payload: self).post()
			}
		}
	}
}

// MARK: - Laravel

/// A Laravel compatible Alamofire event monitor.
///
/// The monitor will automatically update the maintenance mode status.
public struct LaravelMaintenanceModeEventMonitor: EventMonitor {
	private let manager: MaintenanceMode.Manager

	public init(manager: MaintenanceMode.Manager) {
		self.manager = manager
	}

	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard let statusCode = (task.response as? HTTPURLResponse)?.statusCode else { return }
		// Laravel returns a 503 status code when in maintenance mode
		manager.setMaintenanceModeEnabled(statusCode == 503)
	}
}

/// A Laravel compatible maintenance mode checker.
public struct LaravelMaintenanceModeChecker<C: Client>: MaintenanceModeChecker {
	private let client: C
	private let route: C.RouterType

	public init(client: C, route: C.RouterType) {
		self.client = client
		self.route = route
	}

	public func checkMaintenanceMode(then handler: @escaping (Bool?) -> Void) {
		client.request(route).response { response in
			if response.response?.statusCode == nil {
				handler(nil)
			} else {
				let inMaintenanceMode = LaravelMaintenanceModeResponseChecker.inMaintenanceMode(response: response)
				handler(inMaintenanceMode)
			}
		}
	}
}

/// A Laravel compatible response maintenance mode checker.
public enum LaravelMaintenanceModeResponseChecker: MaintenanceModeResponseChecker {
	public static func inMaintenanceMode<T>(response: DataResponse<T, AFError>) -> Bool {
		// Laravel returns a 503 status code when in maintenance mode
		response.response?.statusCode == 503
	}
}
