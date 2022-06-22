//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Combine
import Foundation

@available(iOS 13.0, *)
public extension SingleObjectRepository {
	func refresh() -> AnyPublisher<Result<ObjectType, Error>, Never> {
		Future { promise in
			self.refresh { promise(.success($0)) }
		}
		.eraseToAnyPublisher()
	}
}
