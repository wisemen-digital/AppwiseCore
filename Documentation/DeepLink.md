# DeepLink

Useful for handling universal links, custom protocols and push notifications.ee

- For each "screen" in your app, you need to register that screen: `.register(_, for:)`
- Works with a "stack" of screens.
- View controllers must implement `DeepLinkMatchable`:
  - `dismiss(...)`: dismiss one (or more) stack items (if you can).
  - `present(...)`: present a stack item (only 1).
- Open a deep link with `DeepLinker.shared.open(path:, animated:)`.
- If you can't fully handle a deep link, it will (temporarily) be stored until the next register (or open).

## Notes

- Remember: it only handles 1 stack of screens.
- Recommended to register your root controller (tabbar?) as "root".
- Register in each of your screens, so it knows which screen is active.
