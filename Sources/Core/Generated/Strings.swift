// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {

  internal enum Client {
    internal enum Error {
      /// Unauthorized access, session may have expired.
      internal static let unauthorized = L10n.tr("Localizable", "client.error.unauthorized")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static let bundle = Bundle(for: BundleToken.self)
  private static let resourcesBundle: Bundle = {
    guard let url = bundle.url(forResource: "AppwiseCore-Core", withExtension: "bundle"),
      let bundle = Bundle(url: url) else {
      fatalError("Can't find 'AppwiseCore-Core' resources bundle")
    }
    return bundle
  }()

  private static func tr(_ table: String, _ key: String) -> String {
    return NSLocalizedString(key, tableName: table, bundle: resourcesBundle, comment: "")
  }

  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: resourcesBundle, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}

