//
//  DefaultDirectories.swift
//  AppwiseCore
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2019 Appwise. All rights reserved.
//

import Foundation

public extension FileManager {
	/// The document directory of your application
	var documentsDirectory: URL? {
		return urls(for: .documentDirectory, in: .userDomainMask).last
	}

	/// The support directory of your application
	var supportDirectory: URL? {
		guard let dir = urls(for: .applicationSupportDirectory, in: .userDomainMask).last,
			let name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String,
			let escaped = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return nil }

		return URL(string: escaped, relativeTo: dir)
	}
}
