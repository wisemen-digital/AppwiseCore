# Change Log
All notable changes to this project will be documented in this file.
`AppwiseCore` adheres to [Semantic Versioning](http://semver.org/).

## [Master](https://github.com//AppwiseCore)

### New Features

* Added application services to the app delegate.

### Breaking

* AppDelegate: all UIAppDelegate implementations are now `public` instead of `open`. To add an override please use application services.

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
