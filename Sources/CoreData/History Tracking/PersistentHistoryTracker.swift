//
// AppwiseCore
// Copyright © 2022 Appwise
//

import CocoaLumberjack
import CoreData

final class PersistentHistoryTracker {
	private let author: Author
	private let settings: PersistentHistorySettings
	private let store: NSPersistentStore
	private let persistentContainer: NSPersistentContainer

	private lazy var historyQueue: OperationQueue = {
		let queue = OperationQueue()
		queue.maxConcurrentOperationCount = 1
		return queue
	}()

	public init(author: Author, settings: PersistentHistorySettings, store: NSPersistentStore, persistentContainer: NSPersistentContainer) {
		self.author = author
		self.settings = settings
		self.store = store
		self.persistentContainer = persistentContainer
	}
}

// MARK: - Actions

extension PersistentHistoryTracker {
	func start() {
		if #available(iOS 13, *) {
			NotificationCenter.default.addObserver(
				self,
				selector: #selector(processStoreRemoteChanges),
				name: .NSPersistentStoreRemoteChange,
				object: persistentContainer.persistentStoreCoordinator
			)

			NotificationCenter.default.addObserver(
				self,
				selector: #selector(scheduleCleanup),
				name: UIApplication.didEnterBackgroundNotification,
				object: nil
			)
		}
	}

	func stop() {
		NotificationCenter.default.removeObserver(self)
		historyQueue.cancelAllOperations()
	}
}

// MARK: - Helpers

internal extension PersistentHistoryTracker {
	func didStart() {
		let key = PersistentHistorySettings.Key(storeID: store.identifier, author: author)
		settings.updateLastHistory(key: key, date: Date())

		if #available(iOS 13, *) {
			scheduleCleanup()
		}
	}

	func reset() {
		settings.reset(storeID: store.identifier)
	}
}

// MARK: - Notifications

@available(iOS 13, *)
private extension PersistentHistoryTracker {
	/// Process persistent history to merge changes from other coordinators.
	@objc func processStoreRemoteChanges(notification: Foundation.Notification) {
		guard let info = notification.userInfo, let identifier = info[NSStoreUUIDKey] as? String,
		      store.identifier == identifier else { return }

		historyQueue.addOperation { [weak self] in
			self?.processPersistentHistory()
		}
	}

	@objc func scheduleCleanup() {
		historyQueue.addOperation { [weak self] in
			self?.cleanupHistory()
		}
	}
}

// MARK: - Notifications

@available(iOS 13, *)
private extension PersistentHistoryTracker {
	func processPersistentHistory() {
		let context = persistentContainer.newBackgroundContext()
		context.transactionAuthor = author.name
		context.performAndWait {
			do {
				let merger = PersistentHistoryMerger(store: store, author: author, backgroundContext: context, viewContext: persistentContainer.viewContext, settings: settings)
				try merger.merge()

				let cleaner = PersistentHistoryCleaner(store: store, context: context, settings: settings)
				try cleaner.clean()
			} catch {
				DDLogError("Persistent history tracking: process failed \(error)")
			}
		}
	}

	func cleanupHistory() {
		let context = persistentContainer.newBackgroundContext()
		context.transactionAuthor = author.name
		context.performAndWait {
			do {
				let cleaner = PersistentHistoryCleaner(store: store, context: context, settings: settings)
				try cleaner.clean()
			} catch {
				DDLogError("Persistent history tracking: cleanup failed \(error)")
			}
		}
	}
}
