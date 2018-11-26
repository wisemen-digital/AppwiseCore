# AppwiseCore

[![Version](https://img.shields.io/cocoapods/v/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![License](https://img.shields.io/cocoapods/l/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![Platform](https://img.shields.io/cocoapods/p/AppwiseCore.svg?style=flat)](https://cocoapods.org/pods/AppwiseCore)
[![Swift version](https://img.shields.io/badge/Swift-4.2-orange.svg)](https://cocoapods.org/pods/AppwiseCore)

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

We recommend you take a look at the [Example](https://github.com/appwise-labs/AppwiseCore-Example) project, it contains most of the basic structure we use in each project.

The library is split up into a few sub libraries, mostly one for each purpose:

- [Common](Documentation/Common.md): Common code and utilities.
- [UIApplication](Documentation/UIApplication.md): Pluggable app delegate (application services).
- [Core](Documentation/Core.md): The main library, things like Config, Settings, Networking, ...
- [CoreData](Documentation/CoreData.md): Integration with core data and groot, Importable and other helpers.
- [UI](Documentation/UI.md): Some fixes for UIKit weirdness.
- [Behaviours](Documentation/Behaviours.md): Mechanism for using common code in multiple controllers, with some built-in behaviours.
- [DeepLink](Documentation/DeepLink.md): Simple deep linking library.


## Authors

* [David Jennes](https://github.com/djbe)
* [Jonas Beckers](https://github.com/jonasbeckers)
* [Tom Knapen](https://github.com/wassup-)

This framework contains source code based on:

* [AlamofireCoredata](https://github.com/ManueGE/AlamofireCoreData) by [Manuel García-Estañ](https://github.com/ManueGE)
* [Lifecycle behaviours](https://irace.me/lifecycle-behaviors) by [Bryan Irace](https://github.com/irace)
* [PluggableApplicationDelegate](https://github.com/fmo91/PluggableApplicationDelegate) by [Fernando Martín Ortiz](https://github.com/fmo91)
* [Require](https://github.com/JohnSundell/Require) by [John Sundell](https://github.com/JohnSundell)
* [TypedNotifications](https://github.com/mergesort/TypedNotifications) by [Joe Fabisevich](https://github.com/mergesort/TypedNotifications)

## License

AppwiseCore is available under the MIT license. See the LICENSE file for more info.
