# CoreData

- `DB` is an interface to the underlying SugarRecord/CoreData stack
- Use `DB.shared`
- You can have other stores, use the `DB(bundle:)` initializer, and call `initialize(storeName:)` afterwards.
- Use `.operation(...)` and `.backgroundOperation(...)` as needed, it's not recommended to create your own contexts.
- If you really need to have your own MOC, call `.newSave()`

## MOC

Adds a few useful functions, such as:

- `.first(...)` based on import primary key, or using your own key or sorting.
- `.inContext()` to switch contexts.
- `.findOldItems(...)` for use during import.
- `.removeAll()`: careful, you need to reload manually!

## Importing

- Use `.requestInsert(...)` to auto-import.
- `Wrapper` can be useful for metadata (pagination).
- `Importable` protocol for callbacks for each item, or all items.

Example of a `Wrapper` for pagination:
```swift
struct PaginatedFeedItem: Wrapper, Importable {
  private enum Key {
    static let content = "content"
    static let pageNumber = "pageNumber"
    static let totalPages = "totalPages"
  }

  var content: [FeedItem] = []
  var pageNumber = 0
  var totalPages = 1

  mutating func map(_ map: Map) {
    content <- map[Key.content]
    pageNumber <- map[Key.pageNumber]
    totalPages <- map[Key.totalPages]
  }

  func inContext(_ context: NSManagedObjectContext) throws -> PaginatedFeedItem {
    var result = self
    result.content = try content.map { try context.inContext($0) }
    return result
  }

  func didImport(from json: Any, in context: ImportContext) throws {
    guard let json = json as? [String: Any],
      let data = json[Key.content] as? [Any] else { return }
    try content.didImport(from: data, in: context)
  }
}
```
