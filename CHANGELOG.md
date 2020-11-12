# Change Log

All notable changes to this project will be documented in this file.
`AppwiseCore` adheres to [Semantic Versioning](http://semver.org/).

## [Master](https://github.com/appwise-labs/AppwiseCore)

### Improvements

* Core: `Router` now supports an `anyParams` property which you can use with `JSONEncoding` to send (for example) an `Array` instead of a `Dictionary`.

### Bug Fixes

* Fastlane: import localization files sorted by name.

## [1.3.6](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.3.6)

### Bug Fixes

* Fastlane: fix some special cases in `export_localizations` (units with no translations, etc...).
* Fastlane: do not try to merge localization xliff that does not exist (in `export_translations`).

## [1.3.5](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.3.5)

### Improvements

* Fastlane: add `sync_localizations` action that imports and then exports strings in one go.

### Bug Fixes

* Fastlane: The `import_localizations` action avoids needlessly changing the xliffs.
* Fastlane: The `export_localizations` action now preserves weblate status flags.
* Rome: fix xcodegen issue where it generated invalid projects (for fastlane & CI).

## [1.3.4](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.3.4)

### Improvements

* Fastlane: The export/import translations actions now ensure the source language is `en_devel`, to better integrate with Weblate.
* Core Data: Add some helper methods to object list repositories, such as getting all objects, the count of objects, or if there are any results.
* UI: Add some common classes such as `IntrinsicImageView` (maintains ratio) and `HairLineView` (thinnest line depending on device).
* UI: correctly embed child controllers with insets using `EmbedWithInsetsSegue` and `EmbedInsetsBehaviour` (supports top & bottom insets).

## [1.3.3](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.3.3)

### Bug Fixes

* Fastlane: improve `sentry_auto_set_commits` handling of some Git URL variations.

## [1.3.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.3.2)

### Bug Fixes

* Fastlane: fixed Sentry set-commits step for repositories with no tags.
* Rome: revert skip project generation step on CI, it doesn't belong here.

## [1.3.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.3.1)

### Improvements

* Rome: Skip project generation step on CI, as it has no purpose. We assume that your project is committed along with other related files.

## [1.3.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.3.0)

### Breaking

* AppwiseCore now depends on Sentry 5.0, update your client initialisation code accordingly.
* The built-in build steps depend on filelists that you should provide. Check the example project for a generic set of input/output file lists.

### Bug Fixes

* UI: fix some cases where resizable UITableView headers/footers weren't sizing correctly.
* AppDelegate: replace TTY logger by OS logger (as we only support iOS 10+).

### Improvements

* Sourcery: Disable SwiftLint for generated files

## [1.2.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.2.2)

### New Features

* Script: Renamed the podfile script (`generate_project.rb`) to `cocoapods_rome.rb` & add some common steps:
  * Use the `interface_builder_integration` function in `pre_compile` to fix interface builder integration with pre-compiled frameworks (missing public headers).
  * Use the `force_bitcode` function in `pre_compile` to ensure frameworks are pre-compiled with Bitcode.

## [1.2.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.2.1)

### New Features

* Fastlane: add actions for translations steps: `export_localizations` and `import_localizations`.
* Fastlane: add action for automatically linking commits to a sentry release: `sentry_auto_set_commits`.

## [1.2.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.2.0)

### New Features

* Script: Add more scripts for the common build steps, and improve them to check for tool availability & whether it is running on CI or during an archive.
* Script: Added script & template for project generation using XcodeGen.
  * Use the `generate_project` function from `generate_project.rb` to trigger generate the necessary files and your project, based on your Podfile.
  * Include the `target-templates.yml` file, and use the `iOS App` target template to add most commonly used build steps.

### Bug Fixes

* DB: `var` declarations must be `dynamic` as well as `@NSManaged`.

## [1.1.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.1.1)

### New Features

* Core: improved the network error parser, it now supports sub-errors.

### Bug Fixes

* CoreData: fixed a bug for data models when used inside frameworks.

## [1.1.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.1.0)

### New Features

* AutoViewModel template now supports adding extra imports using the `extraImports` variable.

### Bug Fixes

* AutoViewModel won't generate getters for `private` properties.

## [1.0.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.0.2)

### New Features

* The default `Client` error parser tries to ignore HTML errors.

## [1.0.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.0.1)

### Bug Fixes

* Core: rename `ViewModel.Model` to `ViewModel.ModelType` to avoid conflicts with `Model` namespace. This shouldn't impact anyone unless you were directly referencing the associated type.
* Core: fallback to CFBundleName if CFBundleDisplayName is empty.

## [1.0.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/1.0.0)

### Breaking

* Dropped support for iOS 9.0.
* Removed SugarRecord as a dependency.
* DB: rewritten to use `NSPersistentContainer`.
* Core: renamed `ViewModel` to `ViewModelType` (so we can have a `ViewModel` namespace).
* Upgraded to Swift 5.0.

### New Features

* Core: add `Identifiable` protocol for easy `Identifier` phantom types.
* Core: add `PushNotificationType` protocol for parsing incoming pushes.
* Deeplink: add shortcut method for opening a list of path elements.
* UIApplication: make spec compatible with app extensions.
* New SwiftGen templates for CoreData code generation: `CoreData.stencil` (similar to built-in template) and `CoreData (KeyPaths).stencil` (for `#keyPath` use).

### Bug Fixes

* Deeplink: fix issue with VCs with child deeplink matchables (for example a segmented tabcontroller).

## [0.12.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.12.2)

### Bug Fixes

* Behaviours: ensure the hidden behaviour VC doesn't conflict with auto-insetting/large title hiding (scrollviews).
* AutoVM: avoid infinite recursion for unknown super types.

## [0.12.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.12.1)

### Bug Fixes

* AutoVM: fix bug where properties of super-types weren't generated.

## [0.12.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.12.0)

### Breaking

* DB: `Wrapper.map(_:)` is now a throwing function, along with some of the `<-` operators.

### New Features

* New `AutoModel` sourcery template to generate `Model`-namespaced typealiases for your model types. The `AutoViewModel` template has been updated to handle this change.
* DB: Improved the propagation of errors from inside `Wrapper.map(_:)`. Accordingly, some of the `<-` operators are now throwing as well, just use `try` and `map(_:)` will catch it.

### Bug Fixes

* DB: fix another deadlock that could happen during some saves.
* AutoViewModel: fixed sourcery crash by checking for empty types.

## [0.11.3](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.11.3)

### Bug Fixes

* DB: fix a deadlock that could happen during some saves.

## [0.11.2](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.11.2)

### New Features

* DB: add a merge policy property, and set it to `mergeByPropertyStoreTrump` by default.

### Bug Fixes

* AutoViewModel: fix bug that broke auto `vm` property generation.

## [0.11.1](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.11.1)

### Bug Fixes

* Core: fix crash on startup do to `Version` not being archivable.

## [0.11.0](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.11.0)

### Breaking

* Core: the `Version` provided by `Config.handleUpdate(from:, to:)` and `Config.appVersion` is now an actual structured type, instead of a plain string.

### New Features

* DeepLink: you can now see if there's a scheduled route, and cancel it if needed.

### Bug Fixes

* DeepLink: fixed a bug where the internal state was wrong when switching tabs with navigation controllers (where you weren't in the first view controller).

### Internal

* Update to SwiftLint 0.28.

## [0.10.7](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.7)

### New Features

* Core: split off the application delegate and services into a separate subspec `UIApplication`, so that the `Core` subspec can be used in application extensions.
* Behaviours: added a new `RefreshOnAppearBehaviour`, that by default will only trigger a refresh if the appear is **not** from a pop navigation.

## [0.10.6](https://github.com/appwise-labs/AppwiseCore/releases/tag/0.10.6)

### Bug Fixes

* DeepLink: fix a crash when opening a link if the stack was empty (i.e. on app startup).

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
