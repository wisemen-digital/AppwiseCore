import PackageDescription

let package = Package(
	name: "AppwiseCore",
	dependencies: [
		.Package(url: "https://github.com/duemunk/Async.git", majorVersion: 2),
		.Package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", majorVersion: 3),
		.Package(url: "https://github.com/AnthonyMDev/CrashlyticsRecorder.git", majorVersion: 2)
	]
)
