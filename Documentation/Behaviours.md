# Behaviours

Instead of writing (and repeating) a bunch of code in each controller's `will/didAppear` (and other moments), use behaviours! It's kind of similar to application services.

To add behaviours to your view controller:

```swift
override func viewDidLoad() {
  super.viewDidLoad()

  add(behaviours: [
    HideNavbarHairlineBehaviour(),
    RefreshOnAppearBehavior(delegate: self)
  ])
}
```

There are some built-in behaviours for the more common cases:

- `ApplicationEventBehavior`: enter foreground/background events.
- `DismissKeyboardBehaviour`: dismiss keyboard on disappear.
- `HideShowNavigationBarBehaviour`: show/hide the navigation bar on push/pop.
- `RefreshOnAppearBehavior`: trigger a controller's refresh callback on appear (always/no pop).
