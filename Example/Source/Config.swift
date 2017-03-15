//
//  Config.swift
//  Example
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import AppwiseCore

enum Router: String, AppwiseCore.Router {
	static var baseURLString = "http://google.com"
	
	case ab
	case cd
	case helloWorld
	
	var path: String {
		return "/"
	}
}

struct Config: AppwiseCore.Config {
	static let shared = Config()

	func initialize() {
	}

	func teardown() {
	}
}
