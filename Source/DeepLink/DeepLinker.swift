//
//  DeepLinker.swift
//  AppwiseCore
//
//  Created by David Jennes on 03/11/17.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation

public struct DeepLinkStackItem {
	public let path: String
	weak var matchable: DeepLinkMatchable?
}

public final class DeepLinker {
	typealias Stack = [DeepLinkStackItem]
	public static let shared = DeepLinker()

	private var stack: Stack = []
	private var scheduledRoute: [String]?

	private init() {
	}

	public func register(_ matchable: DeepLinkMatchable & UIViewController, for path: String) {
		if let vc = matchable as? UITabBarController {
			addToStack(matchable, for: path)
		} else {
			let behaviour = DeepLinkMonitorBehaviour(matchable, for: path)
			matchable.add(behaviours: [behaviour])
		}
	}

	func addToStack(_ matchable: DeepLinkMatchable, for path: String) {
		guard !stack.flatMap({ $0.matchable }).contains(where: { $0.isEqual(matchable) }) else { return }

		stack = cleanupWeakReferences()
		stack.append(DeepLinkStackItem(path: path, matchable: matchable))

		if let route = scheduledRoute, navigate(to: route) {
			scheduledRoute = nil
		}
	}

	func removeFromStack(_ matchable: DeepLinkMatchable) {
		stack = cleanupWeakReferences().filter { !($0.matchable?.isEqual(matchable) ?? false) }
	}

	@discardableResult
	public func open(path: String) -> Bool {
		let route = path.split(separator: "/").map { String($0) }
		guard !route.isEmpty else { return false }

		if navigate(to: route) {
			return true
		} else {
			scheduledRoute = route
			return false
		}
	}

	private func cleanupWeakReferences() -> Stack {
		return stack.filter { item in
			return item.matchable != nil
		}
	}
}

// MARK: - Navigation

extension DeepLinker {
	private func navigate(to route: [String]) -> Bool {
		let stack = cleanupWeakReferences()

		// if we don't have a stack, store the request for later
		guard let firstDifferent = findFirstDifferentIndex(stack: stack, route: route) else {
			return false
		}

		// if common < stack -> dismiss stack items
		guard let destroyedStack = destroyStack(existing: stack, to: firstDifferent) else {
			return false
		}

		// if common > stack -> build stack up
		let lastCommon = stack.index(before: firstDifferent)
		guard let builtStack = buildUpStack(existing: destroyedStack, for: route, lastCommon: lastCommon) else {
			return false
		}

		self.stack = builtStack
		return true
	}

	private func findFirstDifferentIndex(stack: Stack, route: [String]) -> Array<String>.Index? {
		if let index = Array(zip(route, stack)).index(where: { $0 != $1.path }),
			index > stack.startIndex {
			return index
		} else {
			return min(route.endIndex, stack.endIndex)
		}
	}

	private func destroyStack(existing: Stack, to index: Int) -> Stack? {
		var stack = existing
		let beforeIndex = stack.index(before: index)

		while stack.count > index {
			let start = stack.index(before: stack.index(before: stack.endIndex))
			guard start >= beforeIndex else { return nil }

			var dismissedSomething = false
			for i in (beforeIndex...start).reversed() {
				guard let parent = stack[i].matchable else { continue }
				let after = stack.index(after: i)

				if parent.dismiss(items: Array(stack.suffix(from: after))) {
					stack = Array(stack.dropLast(stack.endIndex - after))
					dismissedSomething = true
					break
				}
			}

			if !dismissedSomething {
				return nil
			}
		}

		return stack
	}

	private func buildUpStack(existing: Stack, for route: [String], lastCommon: Int) -> Stack? {
		var stack = existing
//
//		for i in 0..<lastCommon {
//			guard let item = stack[i].matchable else { return nil }
//			let next = route.index(after: i)
//
//			_ = item.present(link: Array(route.suffix(from: next)), exists: true)
//		}

		for i in lastCommon..<route.index(before: route.endIndex) {
			guard let item = stack[i].matchable else { return nil }
			let next = route.index(after: i)

			if let matchable = item.present(link: Array(route.suffix(from: next)), exists: false) {
				stack.append(DeepLinkStackItem(path: String(route[next]), matchable: matchable))
			} else {
				return nil
			}
		}

		return stack
	}
}
