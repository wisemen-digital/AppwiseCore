//
//  Require.swift
//  AppwiseCore
//
//  Created by David Jennes on 01/12/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

// Credit to John Sundell for the original implementation:
// https://github.com/JohnSundell/Require
// Last sync on 19 November 2017

public extension Optional {
	/// Require this optional to contain a non-nil value
	///
	/// This method will either return the value that this optional contains, or trigger
	/// a `preconditionFailure` with an error message containing debug information.
	///
	/// - parameter hint: Optionally pass a hint that will get included in any error
	///                   message generated in case nil was found.
	///
	/// - return: The value this optional contains.
	func require(
		hint hintExpression: @autoclosure () -> String? = nil,
		file: StaticString = #file,
		line: UInt = #line
	) -> Wrapped {
		guard let unwrapped = self else {
			var message = "Required value was nil in \(file), at line \(line)"

			if let hint = hintExpression() {
				message.append(". Debugging hint: \(hint)")
			}

			let exception = NSException(
				name: .invalidArgumentException,
				reason: message,
				userInfo: nil
			)
			exception.raise()

			preconditionFailure(message)
		}

		return unwrapped
	}
}
