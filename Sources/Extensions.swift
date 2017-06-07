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

import UIKit

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
    guard let instance = Bundle.main.loadNibNamed(String(describing: T.self), owner: owner)?.first as? T else {
      fatalError("Could not instantiate from nib: \(T.self)")
    }
    return instance
  }
}


/// Extension for CGRect
extension CGRect {
  public var mid: CGPoint { return CGPoint(x: self.midX, y: self.midY) } // computed property, calculated every time
}


/// Extensions for UIApplication
extension UIApplication {
  public static var statusbarHeight: CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return min(CGFloat(statusBarSize.width), CGFloat(statusBarSize.height))
  }
}


/// Extensions for UIColor
extension UIColor {
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
extension UIColor: CustomReflectable {
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
extension UIImage {

  // extensions cannot store properties, has to use computed property, calculated every time
  public var templateImage: UIImage { return withRenderingMode(.alwaysTemplate) }
}

/// UIImageView assets
extension UIImageView {

  // extensions cannot store properties, has to use computed property, calculated every time
  public var templateView: UIImageView { return UIImageView(image: image?.templateImage) }
}


/// Extensions for UILabel
extension UILabel {
  public func tabularize() {
    let attributes = font.fontDescriptor.fontAttributes
    guard attributes[UIFontDescriptorFeatureSettingsAttribute] == nil else { return }

    /// Change the font layout for numbers to use tabular (monospaced) style
    let descriptor = font.fontDescriptor.addingAttributes([
      UIFontDescriptorFeatureSettingsAttribute: [
        [
          UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
          UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
        ]
      ]
      ])
    font = UIFont(descriptor: descriptor, size: font.pointSize)
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
extension UIStoryboard {

  /// instantiate view Controller
  public func instantiate<T: UIViewController>(_: T.Type) -> T {

    guard let vc = self.instantiateViewController(withIdentifier: String(describing: T.self)) as? T else {
      fatalError("Couldn’t instantiate view controller with identifier \(String(describing: T.self)) ")
    }
    return vc
  }
}

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
