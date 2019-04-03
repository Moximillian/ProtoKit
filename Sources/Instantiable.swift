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

extension ViewController {
  /// instantiate Self from a specific Storyboard
  public static func instantiate(storyboardName name: String) -> Self {

    let storyboard = Storyboard(name: name, bundle: nil)
    #if swift(<5.1)
    return asSelf(object: storyboard.instantiateViewController(withIdentifier: identifier),
                  "Couldn’t instantiate view controller with identifier: " + identifier)
    #else
    #if canImport(UIKit)
    guard let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier: " + identifier)
    }

    #elseif canImport(AppKit)
    guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier: " + identifier)
    }

    #endif
    return viewController
    #endif
  }
}

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

extension View {
  /// instantiate Self from Nib in Bundle
  public static func instantiateFromNib(owner: Any? = nil) -> Self {

    #if swift(<5.1)
    return asSelf(object: Bundle.main.loadNibNamed(identifier, owner: owner)?.first,
                  "Could not instantiate from nib: " + identifier)
    #else
    #if canImport(UIKit)
    guard let view = Bundle.main.loadNibNamed(identifier, owner: owner)?.first as? Self else {
      fatalError("Could not instantiate from nib: " + identifier)
    }

    #elseif canImport(AppKit)
    var objects: NSArray?
    Bundle.main.loadNibNamed(identifier, owner: owner, topLevelObjects: &objects)
    guard let view = objects?.first as? Self else {
      fatalError("Could not instantiate from nib: " + identifier)
    }
    #endif

    return view
    #endif
  }
}
