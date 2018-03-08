# Change Log

All notable changes to this project will be documented in this file.
`AppwiseCore` adheres to [Semantic Versioning](http://semver.org/).

## [Master](https://github.com//AppwiseCore)

### New Features

* Core Data: some tweaks to the `Importable` protocol (more default implementations)

## [0.8.7](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.7)

### New Features

* Core Data: added new protocol `Importable` for easier post-processing of imported entities.

### Internal

* Greatly improved the performance of `findOldItems(filter:)` for large data sets.

## [0.8.6](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.6)

### New Features

* Updated the documentation and sample project to match library changes. The sample project is now a fully featured skeleton project.
* The network `Router` type now supports multipart information.

## [0.8.5](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.5)

### Bug Fixes

* DB: don't block on main thread during merge from save.

## [0.8.4](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.4)

### New Features

* Added `TintedImageView` view for fixing broken tintColor (for template images) in `UIImageView` in XCode 9.

### Bug Fixes

* Version script: Only update the build number for app extensions in archive builds, this fixes an installation bug (during running) due to code signing.

## [0.8.3](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.3)

### Bug Fixes

* Core Data: Reverted the callback queue for insert operations.

## [0.8.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.2)

### Internal

* Update build number script to make the date counter relative to the last commit date.
* Make the library compatible with app extensions.

### Bug Fixes

* Core Data: Fix some issues leading to crashes & deadlocks due to accessing MOCs on the wrong queue.

## [0.8.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.1)

### Internal

* Undo the switch to static_framework for CocoaPods for now.

## [0.8.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.0)

### Breaking

* ViewModel protocol has changed a bit. Essentially, the `data` property is no longer an implicitly unwrapped optional, and the constructor has changed to accept a data argument.

### New Features

* Documented all types and methods.
* Add a sourcery template to automatically generate ViewModel init and properties implementations.

## [0.7.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.7.2)

### Bug Fixes

* Fix the `vm(...)` shorthand method not working correctly for non-optional instances.
* Fix accessibility of some typednotification methods.

## [0.7.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.7.1)

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
