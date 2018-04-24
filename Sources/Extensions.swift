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

#if os(iOS) || os(tvOS)
  import UIKit
  public typealias Application = UIApplication
  public typealias Color = UIColor
  public typealias Image = UIImage
  public typealias ImageView = UIImageView
  public typealias Label = UILabel
  public typealias Font = UIFont
  public typealias FontDescriptor = UIFontDescriptor
#elseif os(macOS)
  import AppKit
  public typealias Application = NSApplication
  public typealias Color = NSColor
  public typealias Image = NSImage
  public typealias ImageView = NSImageView
  public typealias Label = NSTextField
  public typealias Font = NSFont
  public typealias FontDescriptor = NSFontDescriptor
#else
  #if swift (>=4.2)
    #error("Unsupported platform.")
  #endif
#endif

extension RawRepresentable where RawValue == Int {
  /// Return the amount of elements in Int based enum or option set. Works only for sequentially numbered types.
  public static var count: Int {
    for i in 0... {
      guard Self(rawValue: i) != nil else {
        return i
      }
    }
    return 0
  }
}

/// Extensions for Bundle
//
// USAGE
//
// Create nib/xib file and class file you want to use, e.g. MyCustomView.xib and MyCustomView.swift
// Make sure the nib file name and class name are the same
// Make sure MyCustomView class is set in the nib/xib editor
//
// Go to the place in your code where you want to use your nib, e.g.
//
// class MyViewController: UIViewController {
//
// override func viewDidLoad() {
//   super.viewDidLoad()
//     let customView: MyCustomView = Bundle.instantiateNib(owner: self)
//     ...
//   }
// }
extension Bundle {
  public class func instantiateNib<T>(owner: Any? = nil) -> T {
#if os(iOS) || os(tvOS)
    guard let instance = Bundle.main.loadNibNamed("\(T.self)", owner: owner)?.first as? T else {
      fatalError("Could not instantiate from nib: \(T.self)")
    }
#elseif os(macOS)
    var objects: NSArray?
    Bundle.main.loadNibNamed(NSNib.Name(rawValue: "\(T.self)"), owner: owner, topLevelObjects: &objects)
    guard let instance = objects?.first as? T else {
      fatalError("Could not instantiate from nib: \(T.self)")
    }
#endif
    return instance
  }
}


/// Extension for CGRect
extension CGRect {
  public var mid: CGPoint { return CGPoint(x: self.midX, y: self.midY) } // computed property, calculated every time
}

#if os(iOS)
/// Extensions for UIApplication (iOS only feature)
extension Application {
  public static var statusbarHeight: CGFloat {
    let statusBarSize = Application.shared.statusBarFrame.size
    return min(CGFloat(statusBarSize.width), CGFloat(statusBarSize.height))
  }
}
#endif

/// Extensions for UIColor
extension Color {
  /// Create UIColor with 0-255 value range (RGBA)
  public convenience init(_ r: Int, _ g: Int, _ b: Int, _ a: CGFloat) {
    self.init(red:CGFloat(r) / 255.0, green:CGFloat(g) / 255.0, blue:CGFloat(b) / 255.0, alpha:a)
  }

  /// Create UIColor with 0-255 value range (gray + alpha)
  public convenience init(_ g: Int, _ a: CGFloat) {
    self.init(white:CGFloat(g) / 255.0, alpha:a)
  }

  /// Create UIColor from hex string (#FF00FF)
  public convenience init(hex: String) {
    var rgbValue: UInt32 = 0
    let scanner = Scanner(string: hex)
    scanner.scanLocation = 1  // bypass '#'
    scanner.scanHexInt32(&rgbValue)
    self.init(red:CGFloat((rgbValue & 0xFF0000) >> 16)/255.0, green:CGFloat((rgbValue & 0xFF00) >> 8)/255.0, blue:CGFloat(rgbValue & 0xFF)/255.0, alpha: 1.0)
  }
}

/// UIColor extension for human readable object values
extension Color: CustomReflectable {
  public var customMirror: Mirror {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    var rgb: [Int] = [Int(red*255), Int(green*255), Int(blue*255)]
    return Mirror(self, children: [
      "RGBA": "(\(rgb[0]), \(rgb[1]), \(rgb[2]), \(alpha))",
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

/// UIImage assets
extension Image {

  // extensions cannot store properties, has to use computed property, calculated every time
  public var templateImage: Image {
#if os(iOS) || os(tvOS)
    return withRenderingMode(.alwaysTemplate)
#elseif os(macOS)
    isTemplate = true
    return self
#endif
  }
}

/// UIImageView assets
extension ImageView {

  // extensions cannot store properties, has to use computed property, calculated every time
  @available(iOS 10.0, macOS 10.12, *)
  public var templateView: ImageView {
    guard let image = image else { return self }
    return ImageView(image: image.templateImage)
  }
}


#if os(iOS) || os(tvOS)

/// Extensions for UITableView
extension UITableView {
  public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>() -> T {
    guard let cell = dequeueReusableHeaderFooterView(withIdentifier: "\(T.self)") as? T else {
      fatalError("Could not dequeue tableview header/footer view with identifier: \(T.self)")
    }
    return cell
  }

  public func register<T: UITableViewCell>(cell: T.Type) {
    register(T.self, forCellReuseIdentifier: "\(T.self)")
  }

  public func register<T: UITableViewHeaderFooterView>(headerFooterView: T.Type) {
    register(T.self, forHeaderFooterViewReuseIdentifier: "\(T.self)")
  }
}

/// Extensions for UICollectionView
extension UICollectionView {
  public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(T.self)", for: indexPath) as? T else {
      fatalError("Could not dequeue collectionview supplementary view with identifier: \(T.self)")
    }
    return view
  }

  public func register<T: UICollectionViewCell>(cell: T.Type) {
    register(T.self, forCellWithReuseIdentifier: "\(T.self)")
  }

  public func register<T: UICollectionReusableView>(supplementaryView: T.Type, ofKind kind: String) {
    register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: "\(T.self)")
  }
}
#endif
