//
//  Created by Mox Soini
//  https://www.linkedin.com/in/moxsoini
//
//  GitHub
//  https://github.com/moximillian/ProtoKit
//
//  License
//  Copyright © 2018 Mox Soini
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#if os(iOS) || os(tvOS)
#elseif os(macOS)
  import UIKit
  public typealias Storyboard = UIStoryboard
  public typealias ViewController = UIViewController
  import AppKit
  public typealias Storyboard = NSStoryboard
  public typealias ViewController = NSViewController
#else
  #if swift (>=4.2)
    #error("Unsupported platform.")
  #endif
#endif

/// Extension for ViewController
//
//  USAGE:
//  1. In storyboard, set viewcontroller's class as well as identifier to the class name (e.g. MyViewController)
//  2. In code, instantiate viewcontroller with:
//
//  let myVC = MyViewController.instantiate()
//

/// protocol to instantiate Self from storyboard
public protocol Instantiable: class {
  static func instantiate(storyboardName: String) -> Self
}

extension Instantiable where Self: ViewController {
  /// instantiate Self from Storyboard
  public static func instantiate(storyboardName name: String) -> Self {
    #if os(iOS) || os(tvOS)
    let storyboard = Storyboard(name: name, bundle: nil)
    guard let vc = storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier \(Self.self) ")
    }
    #elseif os(macOS)
    let storyboard = Storyboard(name: .init(name), bundle: nil)
    guard let vc = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "\(Self.self)")) as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier \(Self.self) ")
    }
    #endif
    return vc
  }
}

// Apply conformance
extension ViewController: Instantiable {}
