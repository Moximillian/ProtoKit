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

extension ViewController {
  /// instantiate Self from a specific Storyboard
  public static func instantiate(storyboardName name: String) -> Self {

    #if canImport(UIKit)
    let storyboard = Storyboard(name: name, bundle: nil)
    return asSelf(object: storyboard.instantiateViewController(withIdentifier: identifier),
                  "Couldn’t instantiate view controller with identifier: " + identifier)

    #elseif canImport(AppKit)
    let storyboard = Storyboard(name: .init(name), bundle: nil)
    let sceneIdentifier = NSStoryboard.SceneIdentifier(rawValue: identifier)
    return asSelf(object: storyboard.instantiateController(withIdentifier: sceneIdentifier),
                  "Couldn’t instantiate view controller with identifier: " + identifier)
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

    #if canImport(UIKit)
    return asSelf(object: Bundle.main.loadNibNamed(identifier, owner: owner)?.first,
                  "Could not instantiate from nib: " + identifier)

    #elseif canImport(AppKit)
    var objects: NSArray?
    Bundle.main.loadNibNamed(NSNib.Name(rawValue: identifier), owner: owner, topLevelObjects: &objects)
    return asSelf(object: objects?.first,
                  "Could not instantiate from nib: " + identifier)
    #endif
  }
}
