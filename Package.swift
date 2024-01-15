// swift-tools-version:5.6

import PackageDescription

let package = Package(
	name: "AppwiseCore",
	platforms: [
		.iOS(.v12)
	],
	products: [
		.library(name: "AppwiseCore",  targets: ["AppwiseCore"])
	],
	dependencies: [
		.package(url: "https://github.com/shibapm/Komondor.git", from: "1.0.0"),
		.package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.6.0"),
		.package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.2.0"),
		.package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
		.package(url: "https://github.com/getsentry/sentry-cocoa.git", from: "8.0.0"),
		.package(url: "https://github.com/IBAnimatable/IBAnimatable.git", from: "6.1.0")
		// TODO: add Groot
	],
	targets: [
		.target(name: "AppwiseCore", dependencies: [
			"Alamofire",
			.product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
			"IBAnimatable",
			"Then",
			.product(name: "Sentry", package: "sentry-cocoa")
		], path: "Sources")
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
