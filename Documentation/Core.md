# Core

Contains all the main items:

- Config
- Settings
- ViewModel
- Network (Client & Router)
- Typed notifications
- Some minor stuff...

## Config

Protocol with 3 optional functions:

```swift
func initialize()
func teardownForReset()
func handleUpdate(from old: Version, to new: Version)
```

It's invoked from `ConfigurationApplicationService` on `didFinishLaunching`.

See flow examples:

- [Simple setup flow](https://mermaidjs.github.io/mermaid-live-editor/#/view/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG5cbnBhcnRpY2lwYW50IEFwcERlbGVnYXRlXG5wYXJ0aWNpcGFudCBDb25maWdcbnBhcnRpY2lwYW50IFNldHRpbmdzXG5wYXJ0aWNpcGFudCBEQlxuXG5BcHBEZWxlZ2F0ZS0-PkNvbmZpZzogc2V0dXBBcHBsaWNhdGlvbigpXG5hY3RpdmF0ZSBDb25maWdcbkNvbmZpZy0-PlNldHRpbmdzOiBsb2FkKClcbmFjdGl2YXRlIFNldHRpbmdzXG5TZXR0aW5ncy0-PlNldHRpbmdzOiBMb2FkIGRlZmF1bHRzIGZyb20gYnVuZGxlXG5kZWFjdGl2YXRlIFNldHRpbmdzXG5Db25maWctPj5EQjogaW5pdGlhbGl6ZSgpXG5Db25maWctLT4-Q29uZmlnOiBpbml0aWFsaXplKClcbkNvbmZpZy0-PkFwcERlbGVnYXRlOiBzZXR1cEFwcGxpY2F0aW9uKCkgRG9uZVxuZGVhY3RpdmF0ZSBDb25maWdcbiIsIm1lcm1haWQiOnsidGhlbWUiOiJkZWZhdWx0In19)
- [Reset flow](https://mermaidjs.github.io/mermaid-live-editor/#/view/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG5cbnBhcnRpY2lwYW50IFVzZXJcbnBhcnRpY2lwYW50IENvbmZpZ1xucGFydGljaXBhbnQgU2V0dGluZ3NcbnBhcnRpY2lwYW50IERCXG5cblVzZXItPj5Db25maWc6IHJlc2V0QXBwbGljYXRpb24oKVxuYWN0aXZhdGUgQ29uZmlnXG5Db25maWctPj5TZXR0aW5nczogcmVzZXQoKVxuQ29uZmlnLT4-REI6IHJlc2V0KClcbkNvbmZpZy0tPj5Db25maWc6IHRlYXJEb3duRm9yUmVzZXQoKVxuZGVhY3RpdmF0ZSBDb25maWciLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9fQ)
- [Full flow](https://mermaidjs.github.io/mermaid-live-editor/#/view/eyJjb2RlIjoic2VxdWVuY2VEaWFncmFtXG5cbnBhcnRpY2lwYW50IEFwcERlbGVnYXRlXG5wYXJ0aWNpcGFudCBDb25maWdcbnBhcnRpY2lwYW50IFNldHRpbmdzXG5wYXJ0aWNpcGFudCBEQlxuXG5BcHBEZWxlZ2F0ZS0-PkNvbmZpZzogc2V0dXBBcHBsaWNhdGlvbigpXG5hY3RpdmF0ZSBDb25maWdcbkNvbmZpZy0-U2V0dGluZ3M6IHNob3VsZFJlc2V0P1xub3B0IFJlc2V0IG5lZWRlZFxuICAgIENvbmZpZy0-PkNvbmZpZzogcmVzZXRBcHBsaWNhdGlvbigpXG4gICAgYWN0aXZhdGUgQ29uZmlnXG4gICAgQ29uZmlnLT4-U2V0dGluZ3M6IHJlc2V0KClcbiAgICBDb25maWctPj5EQjogcmVzZXQoKVxuICAgIENvbmZpZy0tPj5Db25maWc6IHRlYXJEb3duRm9yUmVzZXQoKVxuICAgIGRlYWN0aXZhdGUgQ29uZmlnXG5lbmRcbkNvbmZpZy0-PlNldHRpbmdzOiBsb2FkKClcbmFjdGl2YXRlIFNldHRpbmdzXG5vcHQgVmVyc2lvbiBDaGFuZ2VkXG4gICAgU2V0dGluZ3MtLT4-Q29uZmlnOiBoYW5kbGVVcGRhdGUoZnJvbTosIHRvOilcbmVuZFxuU2V0dGluZ3MtPj5TZXR0aW5nczogTG9hZCBkZWZhdWx0cyBmcm9tIGJ1bmRsZVxuZGVhY3RpdmF0ZSBTZXR0aW5nc1xuQ29uZmlnLT4-REI6IGluaXRpYWxpemUoKVxuQ29uZmlnLS0-PkNvbmZpZzogaW5pdGlhbGl6ZSgpXG5Db25maWctPj5BcHBEZWxlZ2F0ZTogc2V0dXBBcHBsaWNhdGlvbigpIERvbmVcbmRlYWN0aXZhdGUgQ29uZmlnXG4iLCJtZXJtYWlkIjp7InRoZW1lIjoiZGVmYXVsdCJ9fQ)

Example `handleUpdate` implementation:
```swift
final class MyConfig: Config {
  static var shared = MyConfig()

  func handleUpdate(from old: Version, to new: Version) {
    let components = old.components(separatedBy: ".")
    let old = (major: Int(components[0]) ?? 0, minor: Int(components[1]) ?? 0, bugfix: Int(components[2]) ?? 0)

    // migrating from major 1
    if old.major < 2 {
      moveDataStore()
    }

    // fix a bug in 1.2.x
    if old.major == 1 && old.minor == 2 {
      fixBugIn12()
    }
  }

  private func moveDataStore() {
    print("moving data store!")
  }

  private func fixBugIn12() {
    print("fixing bug!")
  }
}
```

## Settings

Is an abstraction for `UserDefaults`, with some extra sauce used internally:

- Load defaults from settings bundle (see `Config.initialize()`)
- Reset all settings (see `Config.reset()`)
- Keeping track of last run version (see `Config.handleUpdate()`)
- Keeping track of route timestampts (see `Route`)

## ViewModel

Sort of lightweight presenter for a model object. Tips:

- You can use the shortcut `vm(myData)` to create a viewmodel instance.
- Use the provided Sourcery template for automatic viewmodel generation.
- This template will generate getters for model properties, unless you provide your own getter with the same name.

## Network

2-part system:

- Router is an enum with all the routers for a specific API or integration.
- Client actually performs the calls.

Each client must have a router, although you can have more routers (for example for building website URLs).

### Network: Router

Enum with all the endpoints for a given API, integration or website.

- For each endpoint, you can specify the path, HTTP method, headers, params, encoding and multiparts.
- None of these properties are mandatory, except for the `path`.
- `Router` can integrate with `Settings` to check if it should update a resource, using the `shouldUpdate(...)` call.
  - You can `.touch()` a resource when you successfully update it.
  - The default interval for an update trigger is 24 hours.

Example of `shouldUpdate` usage:
```swift
extension APIClient {
  func updateNews() {
    APIRouter.news.shouldUpdate { route, shouldUpdate in
      guard shouldUpdate else { return }

      self.requestJSON(route) { result in
        // on success, touch the resource
        switch result {
        case .success:
          route.touch()
        default:
          break
        }
      }
    }
  }
}
```

### Network: Client

Network client with a mandatory associated `Router` enum.

- Each network client has its own session manager, to prevent blocking between clients.
- Use the `buildRequest` method to convert a `Router` case to a `DataRequest` (async).
- Ideally, use one of the shortcut methods: `requestData`, `requestJSON`, `requestJSONDecodable`, `requestString` or `requestInsert` (see [CoreData](CoreData.md)).
- Use the `extract(...)` method to extract errors from responses. **You can override this!**

## Typed Notifications

Foundation.Notification uses `String`s, which is bad. Use `TypedNotification` instead!

- Very simple protocol, simply define a struct implementing it.
- Use `TypedPayloadNotification` for notifications with a payload.
- Handy shortcut methods `.post()` and `.register(...)`

Example of typed notifications:
```swift
enum Notification {
  struct SelectedCatalog: TypedPayloadNotification {
    let payload: CategoryViewModel
  }

  struct OrderChanged: TypedNotification {
  }
}

final class MyController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    // register
    Notification.SelectedCatalog.register(observer: self, selector: #selector(test(_:)))
  }

  @objc
  private func test(_ notification: Foundation.Notification) {
    guard let item = notification.getPayload(for: Notification.SelectedCatalog.self) else { return }

    navigationItem.title = item.title
  }
}
```

## Other stuff

- `FileManager.default.documentsDirectory` and `.supportDirectory` getters.
- Don't know if you're in the main queue? `DispatchQueue.isMain` to the rescue.
- `CrashlyticsLogger`
