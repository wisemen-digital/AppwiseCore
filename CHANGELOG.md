# Change Log

All notable changes to this project will be documented in this file.
`AppwiseCore` adheres to [Semantic Versioning](http://semver.org/).

## [Master](https://github.com/appwise-labs/AppwiseCore)

## [0.10.5](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.5)

### Bug Fixes

* DB: make `Wrapper` inherit `ManyInsertable`. This means `[Wrapper]`s will be `Insertable`, which matches `AlamofireCoreData` behaviour.

## [0.10.4](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.4)

### New Features

* DB: `Map` (used by `Wrapper`) `context` property is now public, so you can access the context during an import.
* DB: Added a `NSManagedObjectContext.removeAll(of:)` method that uses a batch delete request. Note: this delete won't automatically trigger an update of your context.

## [0.10.3](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.3)

### Bug Fixes

* AutoViewModel: better support for nested (and other) types.

### New Features

* Network: better parsing of structured errors, and store the underlying error should you need it.

## [0.10.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.2)

### New Features

* Core: Add a new network shortcut for loading a `Decodable` object from JSON.

## [0.10.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.1)

### Bug Fixes

* DB: fix insert requests with custom serializers and/or non-default databases, using the shortcut `requestInsert` method.

## [0.10.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.0)

### Breaking

* DB: Removed the `Many` wrapper structure (for `Array`), as Swift no longer needs this (since 4.1). You can simply use `[MyStuff].self` instead of `Many<MyStuff>.self` during insert calls.

### New Features

* Core: translate the user visible errors (such as unauthorized).
* Core: added more network shortcut methods such as `requestJSON` and `requestString`.

## [0.9.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.9.2)

### New Features

* Core: Add a method to extract an nice error from a server's response.
* DB: Add a shortcut method for building a request, performing an insert and saving the result in one go. (see `Client.requestInsert(...)`)

## [0.9.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.9.1)

### Breaking

* DB: The `Importable` and `ManyImportable` protocols are back due to limitations in Swift.

## [0.9.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.9.0)

### Breaking

* DB: AlamofireCoreData has been replaced by a built-in solution. This means that:
  * ~~The `Importable` and `ManyImportable` protocols have been merged into the `Insertable` and `ManyInsertable` protocols respectively.~~ This change was undone in 0.9.1 due to limitations in Swift.
  * There's no longer a `responseInsert` call where you can provide your own `NSManagedObjectContext`.
* Network: remove the old `responseInsert` functions where the completion block accepted a `NSManagedObjectContext` parameter. This has been replaced by the `didImport` functions on `Insertable` types. (see version [0.8.7](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.7))

### New Features

* Swift 4.2 and Xcode 10 support.

### Bug Fixes

* AutoViewModel: add support for nested types.
* Core: fix build number plist key.

## [0.8.12](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.12)

### New Features

* Core: you can now unregister observers from typed notifications.

## [0.8.11](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.11)

### New Features

* Core: you can now provide a timestamp when "touching" a route.

### Bug Fixes

* Script: Only set the version number of DSYM bundles if they exist.

## [0.8.10](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.10)

### Bug Fixes

* DB: Fix a bug where the `Importable` context object was missing.

## [0.8.9](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.9)

### Bug Fixes

* DB: Fix a bug in the keyPath conversion code in `first`.

## [0.8.8](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.8.8)

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
