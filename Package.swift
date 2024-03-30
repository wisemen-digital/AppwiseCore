// swift-tools-version:5.10

import PackageDescription

let package = Package(
	name: "AppwiseCore",
	dependencies: [
		.package(url: "https://github.com/shibapm/Komondor.git", exact: "1.1.3")
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
