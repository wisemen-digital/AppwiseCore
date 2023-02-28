//
// AppwiseCore
// Copyright © 2022 Appwise
//

import AppwiseCore

enum DataBaseHelper {
	static func setupDefault() -> DB {
		DB(bundle: BundleHelper.testBundle, storeName: "db").then {
			$0.reset()
			$0.initialize()
		}
	}
}
