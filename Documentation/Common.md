# Common

Meant for library internal stuff:

- Swift 4 & 4.2 support code.
- Require

## Require

Useful for replacing this:
```swift
guard let value = someValue else {
  fatalError("Missing someValue in ...")
}
```

With this:
```swift
let value = someValue.require("Missing someValue in ...")
```

*Note*: Only use this very sparingly! It's essentially a force unwrap with a nice message.
