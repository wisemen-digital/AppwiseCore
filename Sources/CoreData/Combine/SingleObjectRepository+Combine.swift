//
// AppwiseCore
// Copyright © 2022 Appwise
//

#if canImport(Combine)
import Combine
import Foundation

@available(iOS 13.0, *)
public extension SingleObjectRepository {
	func refresh() -> Future<ObjectType, Error> {
		Future { promise in
			self.refresh(then: promise)
		}
	}
}
#endif
