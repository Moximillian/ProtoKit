//
//  Created by Mox Soini
//  https://www.linkedin.com/in/moxsoini
//
//  GitHub
//  https://github.com/moximillian/ProtoKit
//
//  License
//  Copyright © 2019 Mox Soini
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#if canImport(UIKit)
  import UIKit
  public typealias UnifiedApplication = UIApplication
  public typealias UnifiedColor = UIColor
  public typealias UnifiedImage = UIImage
  public typealias UnifiedImageView = UIImageView
#elseif canImport(AppKit)
  import AppKit
  public typealias UnifiedApplication = NSApplication
  public typealias UnifiedColor = NSColor
  public typealias UnifiedImage = NSImage
  public typealias UnifiedImageView = NSImageView
#else
  #error("Unsupported platform.")
#endif

// MARK: - Base type extensions

// Extension for CGRect
extension CGRect {
  public var mid: CGPoint { return CGPoint(x: self.midX, y: self.midY) } // computed property, calculated every time

  public func radius(_ lineWidth: CGFloat) -> CGFloat {
    return floor(min(midX, midY) - lineWidth / 2.0)
  }
}

// MARK: - Unified extensions

/// Abstracted data type for tables and collections
public struct SectionData<Item> {
  public var items: [Item]
  public let headerTitle: String?
  public let footerTitle: String?

  /// fancy pants convenience init
  public init(_ items: Item..., headerTitle: String? = nil, footerTitle: String? = nil) {
    self.init(items: items, headerTitle: headerTitle, footerTitle: footerTitle)
  }

  public init(items: [Item], headerTitle: String? = nil, footerTitle: String? = nil) {
    self.items = items
    self.headerTitle = headerTitle
    self.footerTitle = footerTitle
  }
}

#if os(iOS)
// Extensions for UIApplication (iOS only feature)
extension UnifiedApplication {
  public static var statusbarHeight: CGFloat {
    let statusBarSize = UnifiedApplication.shared.statusBarFrame.size
    return min(CGFloat(statusBarSize.width), CGFloat(statusBarSize.height))
  }
}
#endif

// Extensions for UIColor
extension UnifiedColor {
  /// Create UIColor with 0-255 value range (RGBA)
  public convenience init(_ red: Int, _ green: Int, _ blue: Int, _ alpha: CGFloat) {
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
  }

  /// Create UIColor with 0-255 value range (gray + alpha)
  public convenience init(_ gray: Int, _ alpha: CGFloat) {
    self.init(white: CGFloat(gray) / 255.0, alpha: alpha)
  }

  /// Create UIColor from hex string (#FF00FF)
  public convenience init(hex: String) {
    var rgbValue: UInt32 = 0
    let scanner = Scanner(string: hex)
    scanner.scanLocation = 1  // bypass '#'
    scanner.scanHexInt32(&rgbValue)
    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16)/255.0,
              green: CGFloat((rgbValue & 0xFF00) >> 8)/255.0,
              blue: CGFloat(rgbValue & 0xFF)/255.0,
              alpha: 1.0)
  }
}

// UIColor extension for human readable object values
extension UnifiedColor: CustomReflectable {
  public var customMirror: Mirror {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    let rgb: [Int] = [Int(red*255), Int(green*255), Int(blue*255)]
    return Mirror(self, children: [
      "RGBA": "(\(rgb[0]), \(rgb[1]), \(rgb[2]), \(alpha))"
      ])
  }

  override open var description: String {
    var result = ""
    for child in customMirror.children {
      result += "\(child.label!)\(child.value)"
    }
    return result
  }
}

// UIImage assets
extension UnifiedImage {

  // extensions cannot store properties, has to use computed property, calculated every time
  public var templateImage: UnifiedImage {
#if canImport(UIKit)
    return withRenderingMode(.alwaysTemplate)
#elseif canImport(AppKit)
    isTemplate = true
    return self
#endif
  }
}

// UIImageView assets
extension UnifiedImageView {

  // extensions cannot store properties, has to use computed property, calculated every time
  @available(iOS 10.0, macOS 10.12, *)
  public var templateView: UnifiedImageView {
    guard let image = image else { return self }
    return UnifiedImageView(image: image.templateImage)
  }
}

#if canImport(UIKit)

// MARK: - dequeues for UIKit Tables and Collections

// extensions for UITableViewCell
extension UITableViewCell: DequeableCell {
  public typealias Collection = UITableView
  public static func dequeueReusable(in collection: UITableView, for indexPath: IndexPath) -> Self {
    #if swift(<5.1)
    return asSelf(object: collection.dequeueReusableCell(withIdentifier: identifier, for: indexPath),
                  "Could not dequeue tableview cell with identifier: " + identifier)
    #else
    guard let cell = collection.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? Self else {
      fatalError("Could not dequeue tableview cell with identifier: " + identifier)
    }
    return cell
    #endif
  }

  public static func register(to table: UITableView) {
    table.register(self, forCellReuseIdentifier: identifier)
  }
}

// extensions for UITableViewCell
extension UITableViewHeaderFooterView {
  public static func dequeueReusable(in table: UITableView) -> Self {
    #if swift(<5.1)
    return asSelf(object: table.dequeueReusableHeaderFooterView(withIdentifier: identifier),
                  "Could not dequeue tableview header footer view with identifier: " + identifier)
    #else
    guard let view = table.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? Self else {
      fatalError("Could not dequeue tableview header footer view with identifier: " + identifier)
    }
    return view
    #endif
  }

  public static func register(to table: UITableView) {
    table.register(self, forHeaderFooterViewReuseIdentifier: identifier)
  }
}

// extensions for UICollectionViewCell
extension UICollectionViewCell: DequeableCell {
  public typealias Collection = UICollectionView
  public static func dequeueReusable(in collection: UICollectionView, for indexPath: IndexPath) -> Self {
    #if swift(<5.1)
    return asSelf(object: collection.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath),
                  "Could not dequeue collectionview cell with identifier: " + identifier)
    #else
    guard let cell = collection.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? Self else {
      fatalError("Could not dequeue collectionview cell with identifier: " + identifier)
    }
    return cell
    #endif
  }

  public static func register(to collection: UICollectionView) {
    collection.register(self, forCellWithReuseIdentifier: identifier)
  }
}

// extensions for UICollectionReusableView
extension UICollectionReusableView {
  public static func dequeueReusable(in collection: UICollectionView, ofKind kind: String,
                                     for indexPath: IndexPath) -> Self {
    #if swift(<5.1)
    return asSelf(object: collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                      withReuseIdentifier: identifier,
                                                                      for: indexPath),
                  "Could not dequeue collectionview supplementary view with identifier: " + identifier)
    #else
    guard let view = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                 withReuseIdentifier: identifier,
                                                                 for: indexPath) as? Self else {
      fatalError("Could not dequeue collectionview supplementary view with identifier: " + identifier)
    }
    return view
    #endif
  }

  public static func register(to collection: UICollectionView, for kind: String) {
    collection.register(self, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
  }
}

#endif

// https://ericasadun.com/2018/12/12/the-beauty-of-swift-5-string-interpolation/
// https://ericasadun.com/2018/12/16/swift-5-interpolation-part-3-dates-and-number-formatters/

// MARK: - String interpolation extensions

// extensions for string interpolation
public extension String.StringInterpolation {
  enum NumberFormat {
    case compact
  }

  /// Date formatting interpolation
  mutating func appendInterpolation(_ value: Date, _ formatter: DateFormatter) {
    appendLiteral(formatter.string(from: value))
  }

  /// Provides `Optional` string interpolation without forcing the
  /// use of `String(describing:)`.
  mutating func appendInterpolation<T>(_ value: T?, default defaultValue: String) {
    if let value = value {
      appendInterpolation(value)
    } else {
      appendLiteral(String(describing: defaultValue))
    }
  }

  // CGFloat Number formatting
  mutating func appendInterpolation(_ value: CGFloat, _ format: NumberFormat) {
    let formatter = NumberFormatter()
    switch format {
    case .compact:
      formatter.numberStyle = .decimal
      formatter.decimalSeparator = ","
      formatter.usesGroupingSeparator = false
    }
    switch value {
    case 0..<10:
      formatter.maximumFractionDigits = 1
      formatter.minimumFractionDigits = 1
    default: // case let v where v >= 10
      formatter.maximumFractionDigits = 0
    }
    appendLiteral(formatter.string(from: value as NSNumber) ?? "")
  }
}

public extension DateFormatter {
  /// Returns an initialized `DateFormatter` instance
  static func format(date: Style, time: Style) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    (formatter.dateStyle, formatter.timeStyle) = (date, time)
    return formatter
  }

  /// Returns an initialized `DateFormatter` instance
  static func format(_ dateFormat: String) -> DateFormatter {
    return DateFormatter().then { $0.dateFormat = dateFormat }
  }
}

