# AppwiseCore

[![Version](https://img.shields.io/cocoapods/v/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![License](https://img.shields.io/cocoapods/l/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![Platform](https://img.shields.io/cocoapods/p/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![Swift version](https://img.shields.io/badge/Swift-4-orange.svg)](https://cocoapods.org/pods/AppwiseCore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Requirements


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. We recommend you use `Bundler` to manage gems, but you can manually install it with the following command:

```bash
$ gem install cocoapods
```

To integrate AppwiseCore into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
use_frameworks!

pod 'AppwiseCore'
```

Then, run the following command:

```bash
$ bundle exec pod install
```


## Usage

Create an implementation of the `Config` protocol, and a subclass of the generic `AppDelegate` class (referencing your config type). If you use networking functionality, it's recommended to use the `Router` and `Client` types.

If you need database functionality, additionally add the "AppwiseCore/CoreData" dependency. It will automatically be initialised as long as you've implemented the AppDelegate & Config types.

We recommend you take a look at the [Example](https://github.com/appwise-labs/AppwiseCore-Example) project, it contains most of the basic structure we use in each project.

### Fabric integration

When using AppwiseCore, you'll want to add Crashlytics logging to your project. To do so, add (and use) the following application service (see [source](https://github.com/appwise-labs/AppwiseCore-Example/blob/master/Example/Application/Sources/Application%20Services/FabricApplicationService.swift)):

```swift
import AppwiseCore
import Crashlytics
import CrashlyticsRecorder
import Fabric

final class FabricApplicationService: NSObject, ApplicationService {
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
		Fabric.with([Crashlytics()])
		_ = CrashlyticsRecorder.createSharedInstance(crashlytics: Crashlytics.sharedInstance())
		_ = AnswersRecorder.createSharedInstance(answers: Answers.self)

		return true
	}
}

// MARK: - Conform Crashlytics & Fabric to recorder protocol

extension Crashlytics: CrashlyticsProtocol {
	public func log(_ format: String, args: CVaListPointer) {
		#if DEBUG
			CLSNSLogv(format, args)
		#else
			CLSLogv(format, args)
		#endif
	}
}

extension Answers: AnswersProtocol {
}
```

## Author

[David Jennes](https://github.com/djbe)

## License

AppwiseCore is available under the MIT license. See the LICENSE file for more info.
