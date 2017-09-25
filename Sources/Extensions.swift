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
  public typealias Storyboard = UIStoryboard
  public typealias ViewController = UIViewController
#elseif os(macOS)
  import AppKit
  public typealias Application = NSApplication
  public typealias Color = NSColor
  public typealias Image = NSImage
  public typealias ImageView = NSImageView
  public typealias Label = NSTextField
  public typealias Font = NSFont
  public typealias FontDescriptor = NSFontDescriptor
  public typealias Storyboard = NSStoryboard
  public typealias ViewController = NSViewController
#endif

extension RawRepresentable where RawValue == Int {
  /// Return the amount of elements in Int based enum or option set. Works only for sequentially numbered types.
  public static var count: Int {
    for i in 0..<Int.max {
      guard self.init(rawValue: i) != nil else {
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
    guard let instance = Bundle.main.loadNibNamed(String(describing: T.self), owner: owner)?.first as? T else {
      fatalError("Could not instantiate from nib: \(T.self)")
    }
#elseif os(macOS)
    var objects: NSArray?
    Bundle.main.loadNibNamed(.init(String(describing: T.self)), owner: owner, topLevelObjects: &objects)
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


/// Extensions for UILabel
extension Label {
  public func tabularize() {
    guard let tabularFont = font else { return }
    let attributes = tabularFont.fontDescriptor.fontAttributes
    guard attributes[.featureSettings] == nil else { return }

    /// Change the font layout for numbers to use tabular (monospaced) style
#if os(iOS) || os(tvOS)
    let features: [FontDescriptor.FeatureKey: Int] = [.featureIdentifier: kNumberSpacingType, .typeIdentifier: kMonospacedNumbersSelector]
#elseif os(macOS)
    let features: [FontDescriptor.FeatureKey: Int] = [.selectorIdentifier: kNumberSpacingType, .typeIdentifier: kMonospacedNumbersSelector]
#endif
    let descriptor = tabularFont.fontDescriptor.addingAttributes([.featureSettings: [features]])
    font = Font(descriptor: descriptor, size: tabularFont.pointSize)
  }
}


/// Extension for UIStoryboard
//
//  USAGE: 
//  1. In storyboard, set viewcontroller's class as well as identifier to the class name (e.g. MyViewController)
//  2. In code, instantiate viewcontroller with:
//
//  let myVC = myStoryboard.instantiate(MyViewController.self)
//
extension Storyboard {

  /// instantiate view Controller
  public func instantiate<T: ViewController>(_: T.Type) -> T {

#if os(iOS) || os(tvOS)
    guard let vc = self.instantiateViewController(withIdentifier: String(describing: T.self)) as? T else {
      fatalError("Couldn’t instantiate view controller with identifier \(String(describing: T.self)) ")
    }
#elseif os(macOS)
  guard let vc = self.instantiateController(withIdentifier: .init(String(describing: T.self))) as? T else {
    fatalError("Couldn’t instantiate view controller with identifier \(String(describing: T.self)) ")
  }
#endif
    return vc
  }
}

#if os(iOS) || os(tvOS)

/// Extensions for UITableView
extension UITableView {
  public func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue tableview cell with identifier: \(T.self)")
    }
    return cell
  }

  public func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(type: T.Type) -> T {
    guard let cell = dequeueReusableHeaderFooterView(withIdentifier: String(describing: T.self)) as? T else {
      fatalError("Could not dequeue tableview header/footer view with identifier: \(T.self)")
    }
    return cell
  }

  public func register<T: UITableViewCell>(cell: T.Type) {
    register(T.self, forCellReuseIdentifier: String(describing: T.self))
  }

  public func register<T: UITableViewHeaderFooterView>(headerFooterView: T.Type) {
    register(T.self, forHeaderFooterViewReuseIdentifier: String(describing: T.self))
  }
}

/// Extensions for UICollectionView
extension UICollectionView {
  public func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue collectionview cell with identifier: \(T.self)")
    }
    return cell
  }

  public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind kind: String, for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue collectionview supplementary view with identifier: \(T.self)")
    }
    return view
  }

  public func register<T: UICollectionViewCell>(cell: T.Type) {
    register(T.self, forCellWithReuseIdentifier: String(describing: T.self))
  }

  public func register<T: UICollectionReusableView>(supplementaryView: T.Type, ofKind kind: String) {
    register(T.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: String(describing: T.self))
  }
}
#endif
