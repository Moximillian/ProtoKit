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
  public typealias UnifiedStoryboard = UIStoryboard
  public typealias UnifiedViewController = UIViewController
  public typealias UnifiedView = UIView
#elseif canImport(AppKit)
  import AppKit
  public typealias UnifiedStoryboard = NSStoryboard
  public typealias UnifiedViewController = NSViewController
  public typealias UnifiedView = NSView
#else
  #error("Unsupported platform.")
#endif

/// Extension for UnifiedViewController
//
//  USAGE:
//  1. In storyboard, set viewcontroller's class as well as identifier to the class name (e.g. MyViewController)
//  2. In code, instantiate viewcontroller with:
//
//  let myVC = MyViewController.instantiate()
//

extension UnifiedViewController {
  /// instantiate Self from a specific Storyboard
  public static func instantiate(storyboardName name: String) -> Self {

    let storyboard = UnifiedStoryboard(name: name, bundle: nil)
    #if canImport(UIKit)
    guard let viewController = storyboard.instantiateViewController(withIdentifier: self.identifier) as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier: " + identifier)
    }

    #elseif canImport(AppKit)
    guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? Self else {
      fatalError("Couldn’t instantiate view controller with identifier: " + identifier)
    }

    #endif
    return viewController
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

extension UnifiedView {
  /// instantiate Self from Nib in Bundle
  public static func instantiateFromNib(owner: Any? = nil) -> Self {

    #if canImport(UIKit)
    guard let view = Bundle.main.loadNibNamed(identifier, owner: owner)?.first as? Self else {
      fatalError("Could not instantiate from nib: " + identifier)
    }

    #elseif canImport(AppKit)
    var objects: NSArray?
    Bundle.main.loadNibNamed(identifier, owner: owner, topLevelObjects: &objects)
    guard let view = objects?.firstObject as? Self else {
      fatalError("Could not instantiate from nib: " + identifier)
    }
    #endif

    return view
  }
}
