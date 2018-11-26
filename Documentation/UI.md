# UI

Consists of a few helper classes, because `UIKit` has some weird default behaviour.

- `NavigationController` and `TabBarController` don't call children for rotation/status bar style.
- `TintedImageView` because `tintColor` application is broken.
- `ResizableTableHeaderFooterView` does what it says, see also [Behaviours](Behaviours.md).
