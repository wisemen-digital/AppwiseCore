# AppwiseCore

[![CI Status](http://img.shields.io/travis/djbe/AppwiseCore.svg?style=flat)](https://travis-ci.org/djbe/AppwiseCore)
[![Version](https://img.shields.io/cocoapods/v/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![License](https://img.shields.io/cocoapods/l/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![Platform](https://img.shields.io/cocoapods/p/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

<a href="https://placehold.it/400?text=Screen+shot"><img width=200 height=200 src="https://placehold.it/400?text=Screen+shot" alt="Screenshot" /></a>


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Requirements


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

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
$ pod install
```


## Usage

Create an implementation of the `Config` protocol, and a subclass of the generic `AppDelegate` class (referencing your config type). If you use networking functionality, it's recommended to use the `Router` and `Client` types.

If you need database functionality, additionally add the "AppwiseCore/CoreData" dependency. It will automatically be initialised as long as you've implemented the AppDelegate & Config types.

### Fabric integration

When using, you'll want to add Crashlytics logging to your project. To do so, add the following logger to your project:

```swift
import Crashlytics
import CrashlyticsRecorder

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

And then create the needed recorders in your app delegate:

```swift
@UIApplicationMain
final class AppDelegate: AppwiseCore.AppDelegate<Config> {
	override func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
		guard super.application(application, willFinishLaunchingWithOptions: launchOptions) else { return false }

		// initialize fabric
		Fabric.with([Crashlytics()])
		_ = CrashlyticsRecorder.createSharedInstance(crashlytics: Crashlytics.sharedInstance())
		_ = AnswersRecorder.createSharedInstance(answers: Answers.self)
		
		return true
	}
}
```

## Author

David Jennes


## License

AppwiseCore is available under the MIT license. See the LICENSE file for more info.
