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

#if canImport(UIKit)
  import UIKit
  public typealias Storyboard = UIStoryboard
  public typealias ViewController = UIViewController
  public typealias View = UIView
#elseif canImport(AppKit)
  import AppKit
  public typealias Storyboard = NSStoryboard
  public typealias ViewController = NSViewController
  public typealias View = NSView
#else
  #error("Unsupported platform.")
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
public protocol InstantiableController: class {
  static func instantiate(storyboardName: String) -> Self
}

extension InstantiableController where Self: ViewController {
  /// instantiate Self from a specific Storyboard
  public static func instantiate(storyboardName name: String) -> Self {
    #if canImport(UIKit)
    let storyboard = Storyboard(name: name, bundle: nil)
    guard let viewController = storyboard.instantiateViewController(withIdentifier: "\(Self.self)") as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier \(Self.self) ")
    }
    #elseif canImport(AppKit)
    let storyboard = Storyboard(name: .init(name), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier(rawValue: "\(Self.self)")
    guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier \(Self.self) ")
    }
    #endif
    return viewController
  }
}

// Apply conformance
extension ViewController: InstantiableController {}

/// Extension for View
//
//  USAGE:
//  1. Create nib/xib file and class file you want to use, e.g. MyCustomView.xib and MyCustomView.swift
//  2. Make sure the nib file name and class name are the same
//  3. Make sure MyCustomView class is set in the nib/xib editor
//  4. In code, instantiate view with:
//
//  let myView = MyView.instantiateFromNib()
//

/// protocol to instantiate Self from storyboard
public protocol InstantiableView: class {
  static func instantiateFromNib(owner: Any?) -> Self
}

extension InstantiableView where Self: View {
  /// instantiate Self from Nib in Bundle
  public static func instantiateFromNib(owner: Any? = nil) -> Self {
    #if canImport(UIKit)
    guard let instance = Bundle.main.loadNibNamed("\(Self.self)", owner: owner)?.first as? Self else {
      fatalError("Could not instantiate from nib: \(Self.self)")
    }
    #elseif canImport(AppKit)
    var objects: NSArray?
    Bundle.main.loadNibNamed(NSNib.Name(rawValue: "\(Self.self)"), owner: owner, topLevelObjects: &objects)
    guard let instance = objects?.first as? Self else {
      fatalError("Could not instantiate from nib: \(Self.self)")
    }
    #endif
    return instance
  }
}

// Apply conformance
extension View: InstantiableView {}
