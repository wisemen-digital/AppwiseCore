//
// AppwiseCore
// Copyright © 2022 Appwise
//

import Foundation

enum BundleHelper {
	static var testBundle: Bundle {
		let bundle = Bundle(for: BundleToken.self)

		if let url = bundle.url(forResource: "Tests", withExtension: "bundle") {
			return Bundle(url: url).require()
		} else {
			fatalError("Test bundle not found")
		}
	}
}

private class BundleToken { }
