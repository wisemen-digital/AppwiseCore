// swift-tools-version:5.6

import PackageDescription

let package = Package(
	name: "AppwiseCore",
	platforms: [
		.iOS(.v12)
	],
	products: [
		.library(name: "AppwiseCoreBehaviours", targets: ["AppwiseCoreBehaviours"]),
		.library(name: "AppwiseCoreCommon", targets: ["AppwiseCoreCommon"]),
		.library(name: "AppwiseCoreCore", targets: ["AppwiseCoreCore"]),
		.library(name: "AppwiseCoreCoreData", targets: ["AppwiseCoreCoreData"]),
		.library(name: "AppwiseCoreDeepLink", targets: ["AppwiseCoreDeepLink"]),
		.library(name: "AppwiseCoreUI", targets: ["AppwiseCoreUI"]),
		.library(name: "AppwiseCoreUIApplication", targets: ["AppwiseCoreUIApplication"])
	],
	dependencies: [
		.package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.2.0"),
		.package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.6.0"),
		.package(url: "https://github.com/IBAnimatable/IBAnimatable.git", from: "6.1.0"),
		.package(url: "https://github.com/shibapm/Komondor.git", from: "1.0.0"),
		.package(url: "https://github.com/getsentry/sentry-cocoa.git", from: "8.0.0"),
		.package(url: "https://github.com/devxoul/Then", from: "3.0.0")
		// TODO: add Groot
	],
	targets: [
		.target(
			name: "AppwiseCoreCommon",
			path: "Sources/Common"
		),
		.target(
			name: "AppwiseCoreBehaviours",
			dependencies: [
				.target(name: "AppwiseCoreCommon"),
				"Then"
			],
			path: "Sources/Behaviours"
		),
		.target(
			name: "AppwiseCoreCore",
			dependencies: [
				"Alamofire",
				.product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
				.target(name: "AppwiseCoreCommon"),
				.product(name: "Sentry", package: "sentry-cocoa"),
				"Then"
			],
			path: "Sources/Core"
		),
		.target(
			name: "AppwiseCoreCoreData",
			dependencies: [
				.target(name: "AppwiseCoreCommon"),
				.target(name: "AppwiseCoreCore")
//				"Groot"
			],
			path: "Sources/CoreData"
		),
		.target(
			name: "AppwiseCoreDeepLink",
			dependencies: [
				.target(name: "AppwiseCoreBehaviours"),
				.target(name: "AppwiseCoreCommon")
			],
			path: "Sources/DeepLink"
		),
		.target(
			name: "AppwiseCoreUI",
			dependencies: [
				.target(name: "AppwiseCoreBehaviours"),
				.target(name: "AppwiseCoreCore"),
				"IBAnimatable"
			],
			path: "Sources/UI"
		),
		.target(
			name: "AppwiseCoreUIApplication",
			dependencies: [
				.target(name: "AppwiseCoreCore")
			],
			path: "Sources/UIApplication"
		)
	]
)

#if canImport(PackageConfig)
import PackageConfig

let config = PackageConfiguration([
	"komondor": [
		"pre-commit": [
			"[ -d ./Example/Pods ] && ./Example/Pods/SwiftFormat/CommandLineTool/swiftformat .",
			"[ -d ./Example/Pods ] && ./Example/Pods/SwiftLint/swiftlint --fix --quiet"
		]
	]
]).write()
#endif
