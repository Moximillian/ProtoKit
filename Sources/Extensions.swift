//
//  Created by Mox Soini
//  https://www.linkedin.com/in/moxsoini
//
//  GitHub
//  https://github.com/moximillian/ProtoKit
//
//  License
//  Copyright © 2015 Mox Soini
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#if canImport(UIKit)
  import UIKit
  public typealias Application = UIApplication
  public typealias Color = UIColor
  public typealias Image = UIImage
  public typealias ImageView = UIImageView
  public typealias Label = UILabel
  public typealias Font = UIFont
  public typealias FontDescriptor = UIFontDescriptor
#elseif canImport(AppKit)
  import AppKit
  public typealias Application = NSApplication
  public typealias Color = NSColor
  public typealias Image = NSImage
  public typealias ImageView = NSImageView
  public typealias Label = NSTextField
  public typealias Font = NSFont
  public typealias FontDescriptor = NSFontDescriptor
#else
  #error("Unsupported platform.")
#endif

extension NSObjectProtocol {
  /// Identifier derived from the name of the class
  public static var identifier: String { return String(describing: Self.self) }
}

// Extension for CGRect
extension CGRect {
  public var mid: CGPoint { return CGPoint(x: self.midX, y: self.midY) } // computed property, calculated every time
}

#if os(iOS)
// Extensions for UIApplication (iOS only feature)
extension Application {
  public static var statusbarHeight: CGFloat {
    let statusBarSize = Application.shared.statusBarFrame.size
    return min(CGFloat(statusBarSize.width), CGFloat(statusBarSize.height))
  }
}
#endif

// Extensions for UIColor
extension Color {
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
extension Color: CustomReflectable {
  public var customMirror: Mirror {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    var rgb: [Int] = [Int(red*255), Int(green*255), Int(blue*255)]
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
extension Image {

  // extensions cannot store properties, has to use computed property, calculated every time
  public var templateImage: Image {
#if canImport(UIKit)
    return withRenderingMode(.alwaysTemplate)
#elseif canImport(AppKit)
    isTemplate = true
    return self
#endif
  }
}

// UIImageView assets
extension ImageView {

  // extensions cannot store properties, has to use computed property, calculated every time
  @available(iOS 10.0, macOS 10.12, *)
  public var templateView: ImageView {
    guard let image = image else { return self }
    return ImageView(image: image.templateImage)
  }
}

#if canImport(UIKit)

// Extensions for UITableView
extension UITableView {

  public func register<T: UITableViewCell>(cell: T.Type) {
    register(T.self, forCellReuseIdentifier: "\(T.self)")
  }

  public func register<T: UITableViewHeaderFooterView>(headerFooterView: T.Type) {
    register(T.self, forHeaderFooterViewReuseIdentifier: "\(T.self)")
  }
}

// Extensions for UICollectionView
extension UICollectionView {

  public func register<T: UICollectionViewCell>(cell: T.Type) {
    register(T.self, forCellWithReuseIdentifier: "\(T.self)")
  }

  public func register<T: UICollectionReusableView>(supplementaryView: T.Type, ofKind kind: String) {
    register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: "\(T.self)")
  }
}

// NOTE: Only using generics ( -> T ) here because Self cannot be used in method body of a class
//       (currenly would need protocols with "where Self: xxx" conformance)

// extensions for UITableViewCell
extension UITableViewCell {
  public static func dequeueReusable<T: UITableViewCell>(in collection: UITableView) -> T {
    guard let cell = collection.dequeueReusableCell(withIdentifier: T.identifier) as? T
      else {
        fatalError("Could not dequeue tableview cell with identifier: " + T.identifier)
    }
    return cell
  }
}

// extensions for UITableViewCell
extension UITableViewHeaderFooterView {
  public static func dequeueReusable<T: UITableViewHeaderFooterView>(in collection: UITableView) -> T {
    guard let view = collection.dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
      fatalError("Could not dequeue tableview header footer view with identifier: " + T.identifier)
    }
    return view
  }
}

// extensions for UICollectionViewCell
extension UICollectionViewCell {
  public static func dequeueReusable<T: UICollectionViewCell>(in collection: UICollectionView,
                                                              for indexPath: IndexPath) -> T {
    guard let cell = collection.dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
        fatalError("Could not dequeue collectionview cell with identifier: " + T.identifier)
    }
    return cell
  }
}

// extensions for UICollectionReusableView
extension UICollectionReusableView {
  public static func dequeueReusable<T: UICollectionReusableView>(in collection: UICollectionView,
                                                                  ofKind kind: String,
                                                                  for indexPath: IndexPath) -> T {
    guard let view = collection.dequeueReusableSupplementaryView(ofKind: kind,
                                                                 withReuseIdentifier: T.identifier,
      for: indexPath) as? T else {
        fatalError("Could not dequeue collectionview supplementary view with identifier: " + T.identifier)
    }
    return view
  }
}

#endif
