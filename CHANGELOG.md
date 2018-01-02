# Change Log

All notable changes to this project will be documented in this file.
`AppwiseCore` adheres to [Semantic Versioning](http://semver.org/).

## [Master](https://github.com//AppwiseCore)

### New Features

* Added build number updater script (`Scripts/update_build_number.sh`).

## [0.7.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.7.0)

### New Features

* Added a typed notifications, with optional typed payloads.

### Internal

* Use the recommended way for nav/tabbarcontroller to ask their children for the preferred status bar style/hidden.
* Switched to static_framework for CocoaPods.

## [0.6.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.6.1)

### Bug Fixes

* Core: Fix crash in CocoaLumberjack Crashlytics logger.

## [0.6.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.6.0)

### New Features

* Added application services to the app delegate.
* Added ViewModel protocol with helpers.

### Breaking

* AppDelegate: all UIAppDelegate implementations are now `public` instead of `open`. To add an override please use application services.
* Config: renamed `teardown()` to `teardownForReset()`.

## [0.5.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.5.0)

### New Features

* DB: added (sync) operation variations that does not return anything.
* Added view controller lifecycle behaviours for:
  * Navigation bar visibility.
  * Application foreground/background listeners.
  * Keyboard dismissal on disappear.
  * Resizable UITableView headers/footers.
* Framework for deep linking and destroying/building up a stack of view controllers.
* Helper for requiring a value from optionals.

### Internal

* Replace our own IBInspectable properties with IBAnimatble dependency.

## [0.4.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.4.0)

### New Features

* DB: Add initializer for custom persistent stores.
* Swift 4 support.

### Bug Fixes

* DB: Convert the result of operations to the main thread.

### Internal

* Remove dependency on AsyncSwift.

### Breaking

* DB: Renamed `save` property to `newSave()` function.
