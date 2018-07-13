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
  public typealias Control = UIControl
  public typealias Button = UIButton
  public typealias GestureRecognizer = UIGestureRecognizer
#elseif canImport(AppKit)
  import AppKit
  public typealias Control = NSControl
  public typealias Button = NSButton
  public typealias GestureRecognizer = NSGestureRecognizer
#else
  #error("Unsupported platform.")
#endif

/// Closurable protocol
public protocol Closurable: NSObject {}
// restrict protocol to only classes => can refer to the class instance in the protocol extension

extension Closurable {

  // Create container for closure, store it and return it
  public func getContainer(for closure: @escaping (Self) -> Void) -> ClosureContainer<Self> {
    let container = ClosureContainer(closure: closure, caller: self)
    store(associatedObject: container)
    return container
  }
}

/// Container class for closures, so that closure can be stored as an associated object
public final class ClosureContainer<T: Closurable> {

  var closure: (T) -> Void
  weak var caller: T?

  init(closure: @escaping (T) -> Void, caller: T?) {
    self.closure = closure
    self.caller = caller
  }

  // method for the target action, visible to UIKit classes via @objc
  @objc func processHandler() {
    if let caller = caller {
      closure(caller)
    }
  }

  // target action
  public var action: Selector { return #selector(processHandler) }
}

// MARK: - closurable for UIControl and NSControl

// Extend protocol instead of the class directly, to target closure parameter to specific subclass, not the parent class.
// Extension for UIControl (including UIButton and UIPageControl) - actions with closure
extension Closurable where Self: Control {
#if canImport(UIKit)
  /// Associates a target closure with the control.
  public func addTarget(for controlEvents: UIControl.Event, closure: @escaping (Self) -> Void) {
    let container = getContainer(for: closure)
    addTarget(container, action: container.action, for: controlEvents)
  }
#elseif canImport(AppKit)
  /// Associates a target closure with the control.
  public func addTarget(closure: @escaping (Self) -> Void) {
    let container = getContainer(for: closure)
    target = container
    action = container.action
  }
#endif
}

// activate protocol extensions
extension Control: Closurable {}

#if canImport(UIKit)
// Only needed for iOS/tvOS
extension Button {
  /// Associates a target closure with the control. This specialized version assumes control event is .touchUpInside.
  public func addTarget(closure: @escaping (Button) -> Void) {
    addTarget(for: .touchUpInside, closure: closure)
  }
}
#endif

// MARK: - closurable for UIGestureRecognizer

/// extension for UIGestureRecognizer - actions with closure
extension GestureRecognizer: Closurable {

  public convenience init(closure: @escaping (GestureRecognizer) -> Void) {
    self.init()
    let container = getContainer(for: closure)
#if canImport(UIKit)
    addTarget(container, action: container.action)
#elseif canImport(AppKit)
    target = container
    action = container.action
#endif
  }

  public func addTarget(closure: @escaping (GestureRecognizer) -> Void) {
    let container = getContainer(for: closure)
#if canImport(UIKit)
    addTarget(container, action: container.action)
#elseif canImport(AppKit)
    target = container
    action = container.action
#endif
  }
}

// MARK: - closurable for UIBarButtonItem

#if canImport(UIKit)
/// extension for UIBarButtonItem - actions with closure
extension UIBarButtonItem: Closurable {

  public convenience init(image: UIImage?, style: UIBarButtonItem.Style = .plain, closure: @escaping (UIBarButtonItem) -> Void) {
    self.init(image: image, style: style, target: nil, action: nil)
    let container = getContainer(for: closure)
    target = container
    action = container.action
  }

  public convenience init(title: String?, style: UIBarButtonItem.Style = .plain, closure: @escaping (UIBarButtonItem) -> Void) {
    self.init(title: title, style: style, target: nil, action: nil)
    let container = getContainer(for: closure)
    target = container
    action = container.action
  }

  public func addTarget(closure: @escaping (UIBarButtonItem) -> Void) {
    let container = getContainer(for: closure)
    target = container
    action = container.action
  }
}
#endif
