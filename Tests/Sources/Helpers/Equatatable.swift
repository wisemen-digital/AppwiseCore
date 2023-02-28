//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Foundation

// https://nilcoalescing.com/blog/CheckIfTwoValuesOfTypeAnyAreEqual/
extension Equatable {
	func isEqual(_ other: any Equatable) -> Bool {
		guard let other = other as? Self else {
			return other.isExactlyEqual(self)
		}
		return self == other
	}

	private func isExactlyEqual(_ other: any Equatable) -> Bool {
		guard let other = other as? Self else {
			return false
		}
		return self == other
	}
}

func areEqual(first: Any, second: Any) -> Bool {
	guard
		let equatableOne = first as? any Equatable,
		let equatableTwo = second as? any Equatable
	else { return false }

	return equatableOne.isEqual(equatableTwo)
}
