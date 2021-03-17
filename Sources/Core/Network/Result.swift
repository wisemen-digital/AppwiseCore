//
// AppwiseCore
// Copyright © 2021 Appwise
//

import Alamofire

public extension Result {
	func asVoid() -> Result<Void> {
		map { _ in }
	}

	/// Returns a new cancelled result.
	static var cancelled: Result {
		.failure(Cancelled())
	}

	/// Returns `true` if this result is cancelled.
	var isCancelled: Bool {
		error is Cancelled
	}

	struct Cancelled: Error {}
}
