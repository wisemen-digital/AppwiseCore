//
//  AppDelegate.swift
//  Example
//
//  Created by David Jennes on 17/09/16.
//  Copyright © 2016 Appwise. All rights reserved.
//

import AppwiseCore

@UIApplicationMain
final class AppDelegate: AppwiseCore.AppDelegate<Config> {
	override var services: [ApplicationService] {
		return [
			FabricApplicationService(),
			KeyboardManagerApplicationService()
		]
	}
}
