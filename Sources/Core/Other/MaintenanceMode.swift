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
	func checkMaintenanceMode(then handler: @escaping (_ enabled: Bool) -> Void)
}

public enum MaintenanceMode {
	/// Returns `true` if maintenance mode is currently enabled.
	private(set) public static var isEnabled: Bool = false

	/// This notification gets posted whenever the app enters maintenance mode.
	public struct EnterMaintenanceMode: TypedNotification {}
	/// This notification gets posted whenever the app exits maintenance mode.
	public struct ExitMaintenanceMode: TypedNotification {}
	/// This notification gets posted whenever the maintenance mode did change.
	public struct MaintenanceModeDidChange: TypedNotification {}

	/// Set whether or not maintenance mode is currently enabled. If maintenance mode has changed, this will send the appropriate local notifications.
	///
	/// If `force` is true, local notifications will be sent regardless of the current maintenance mode.
	public static func setMaintenanceModeEnabled(_ enabled: Bool, force: Bool = false) {
		guard enabled != isEnabled || force else { return }

		isEnabled = enabled

		if enabled {
			EnterMaintenanceMode().post()
		} else {
			ExitMaintenanceMode().post()
		}
		MaintenanceModeDidChange().post()
	}

	public final class Manager {
		private let serialQueue = DispatchQueue(label: "maintenance-mode-manager-queue")
		private let checker: MaintenanceModeChecker
		private var isChecking: Bool = false

		public init(checker: MaintenanceModeChecker) {
			self.checker = checker
		}

		public func check() {
			serialQueue.async { [weak self] in
				guard let self = self, !self.isChecking else { return }

				self.isChecking = true
				self.checker.checkMaintenanceMode { [weak self] enabled in
					self?.serialQueue.async {
						defer { self?.isChecking = false }
						setMaintenanceModeEnabled(enabled)
					}
				}
			}
		}
	}
}

// MARK: - Laravel

/// A Laravel compatible Alamofire event monitor.
///
/// The monitor will automatically update the maintenance mode status.
public struct LaravelMaintenanceModeEventMonitor: EventMonitor {
	public init() {}

	public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
		guard let statusCode = (task.response as? HTTPURLResponse)?.statusCode else { return }
		// Laravel returns a 503 status code when in maintenance mode
		MaintenanceMode.setMaintenanceModeEnabled(statusCode == 503)
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

	public func checkMaintenanceMode(then handler: @escaping (Bool) -> Void) {
		client.request(route).response { response in
			if let statusCode = response.error?.responseCode ?? response.response?.statusCode {
				// Laravel returns a 503 status code when in maintenance mode
				handler(statusCode == 503)
			} else {
				handler(MaintenanceMode.isEnabled)
			}
		}
	}
}
