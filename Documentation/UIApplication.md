# UIApplication

Generic protocol for application delegate with application services.

Why?

- Force use of compartementalized application services instead of a massive app delegate.
- You simply define which services you'd like to use (could even be environment based).
- Integration with `Config`.

## Built-in services

- `AddSkipBackupAttributeApplicationService`: Disables iCloud backup for every file/folder in the "Application Support" folder.
- `ConfigureMainQueueApplicationService`: Ensure you can check which dispatch queue is the main queue.
- `LoggingApplicationService`: Configures CocoaLumberjack and adds a Sentry logger.
- `ConfigurationApplicationService`: Triggers `Config` initialization, see [Config](Core.md#config).

## Your own application services

- Inherit from `ApplicationService` (is the same as `UIApplicationDelegate`).
- Try to keep services small/minimal.
- For launch services, use the correct callback (will/didFinishLaunching).
- **Note**: Don't forget to add the service to the app delegate!

For more information about the topic of application services, check [PluggableApplicationDelegate](https://github.com/fmo91/PluggableApplicationDelegate)
