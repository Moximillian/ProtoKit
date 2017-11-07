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
  public typealias Button = UIButton
  public typealias GestureRecognizer = UIGestureRecognizer
#elseif os(macOS)
  import AppKit
  public typealias Button = NSButton
  public typealias GestureRecognizer = NSGestureRecognizer
#endif

/// Closurable protocol
public protocol Closurable: class {}
// restrict protocol to only classes => can refer to the class instance in the protocol extension

extension Closurable {

  // Create container for closure, store it and return it
  public func getContainer(for closure: @escaping (Self) -> Void) -> ClosureContainer<Self> {
    weak var weakSelf = self
    let container = ClosureContainer(closure: closure, caller: weakSelf)
    // store the container so that it can be called later, we do not need to explicitly retrieve it.
    objc_setAssociatedObject(self, Unmanaged.passUnretained(self).toOpaque(), container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return container
  }
}

/// Container class for closures, so that closure can be stored as an associated object
public final class ClosureContainer<T: Closurable> {

  var closure: (T) -> Void
  var caller: T?

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


/// extension for UIButton - actions with closure
extension Button: Closurable {
#if os(iOS) || os(tvOS)
  public func addTarget(forControlEvents: UIControlEvents = .touchUpInside, closure: @escaping (Button) -> Void) {
    let container = getContainer(for: closure)
    addTarget(container, action: container.action, for: forControlEvents)
  }
#elseif os(macOS)
  public func addTarget(closure: @escaping (Button) -> Void) {
    let container = getContainer(for: closure)
    target = container
    action = container.action
  }
#endif
}

#if os(iOS) || os(tvOS)
/// extension for UIPageControl - actions with closure
extension UIPageControl: Closurable {

  public func addTarget(forControlEvents: UIControlEvents = .valueChanged, closure: @escaping (UIPageControl) -> Void) {
    let container = getContainer(for: closure)
    addTarget(container, action: container.action, for: forControlEvents)
  }
}
#endif


/// extension for UIGestureRecognizer - actions with closure
extension GestureRecognizer: Closurable {

  public convenience init(closure: @escaping (GestureRecognizer) -> Void) {
    self.init()
    let container = getContainer(for: closure)
#if os(iOS) || os(tvOS)
    addTarget(container, action: container.action)
#elseif os(macOS)
    target = container
    action = container.action
#endif
  }

  public func addTarget(closure: @escaping (GestureRecognizer) -> Void) {
    let container = getContainer(for: closure)
#if os(iOS) || os(tvOS)
    addTarget(container, action: container.action)
#elseif os(macOS)
    target = container
    action = container.action
#endif
  }
}

#if os(iOS) || os(tvOS)
/// extension for UIBarButtonItem - actions with closure
extension UIBarButtonItem: Closurable {

  public convenience init(image: UIImage?, style: UIBarButtonItemStyle = .plain, closure: @escaping (UIBarButtonItem) -> Void) {
    self.init(image: image, style: style, target: nil, action: nil)
    let container = getContainer(for: closure)
    target = container
    action = container.action
  }

  public convenience init(title: String?, style: UIBarButtonItemStyle = .plain, closure: @escaping (UIBarButtonItem) -> Void) {
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
