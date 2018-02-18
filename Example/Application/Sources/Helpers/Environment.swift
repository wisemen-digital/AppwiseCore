//
//  Environment.swift
//  Example
//
//  Created by David Jennes on 29/03/2017.
//  Copyright © 2017 Appwise. All rights reserved.
//

import Foundation

enum EnvironmentValue<T> {
	case dev(T)
	case stg(T)
	case prd(T)
}

func env<T>(_ envs: EnvironmentValue<T>...) -> T {
	var defaultValue: T!

	for environment in envs {
		switch environment {
		case .dev(let value):
			#if ENVIRONMENT_DEVELOPMENT
				return value
			#endif
		case .stg(let value):
			#if ENVIRONMENT_STAGING
				return value
			#endif
		case .prd(let value):
			defaultValue = value
		}
	}

	return defaultValue
}
