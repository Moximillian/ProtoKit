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

/// Base protocol for the Dependency container
public protocol DependencyStorage {
  associatedtype DependencyTypes
}

public protocol Assertable {
  func assertDependencies()
}

/// Injectable protocol
public protocol Injectable: DependencyStorage, Assertable {
  var dependencies: DependencyTypes { get set }
}

extension Injectable {
  public func assertDependencies() {
    let typeDescriptions: [Substring] = "\(DependencyTypes.self)".split(separator: " ").filter { $0.contains("Dependency") }
    let types: [String] = typeDescriptions.map { return $0.replacingOccurrences(of: "Dependency", with: "") }
    guard types.count > 0 else {
      print("INJECTABLE ERROR: Dependencies not defined correctly in type \(DependencyTypes.self) used by class \(type(of: self))")
      exit(1)
    }
    let obj = Mirror(reflecting: self.dependencies)
    for var dependencyType in types {
      var found = false
      for variable in obj.children {
        guard let label = variable.label else { continue }
        dependencyType = String(dependencyType.removeFirst()).lowercased() + dependencyType

        guard label == dependencyType else { continue }

        let itemMirror = Mirror(reflecting: variable.value)
        guard itemMirror.displayStyle == .optional else { continue }

        guard itemMirror.children.count != 0 else { continue }
        found = true
        break
      }
      guard found else {
        print("INJECTABLE ERROR: Dependency \(dependencyType) not set in type \(DependencyTypes.self) used by class \(type(of: self))")
        exit(1)
      }
    }
  }
}

//// Method Swizzling Hack: Need to find a way to observe UIViewController methods / events.

private let swizzling: (AnyClass, Selector, Selector) -> () = { forClass, originalSelector, swizzledSelector in
  let originalMethod = class_getInstanceMethod(forClass, originalSelector)!
  let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector)!
  method_exchangeImplementations(originalMethod, swizzledMethod)
}

extension UIViewController {

  public static let classInit: Void = {
    let originalSelector = #selector(viewDidLoad)
    let swizzledSelector = #selector(swizzled_viewDidLoad)
    swizzling(UIViewController.self, originalSelector, swizzledSelector)
  }()

  @objc func swizzled_viewDidLoad() {
    swizzled_viewDidLoad()
    guard let injectable = self as? Assertable else { return }
    injectable.assertDependencies()
  }
}


/*
 //  -------- USAGE ----------

 // 1. Activate swizzling in AppDelegate with:

 func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
   UIViewController.classInit
 }

// 2. Define all your potential dependencies globally, variables must be optional

protocol SomeDependency   { var some: Int?     { get set } }
protocol OtherDependency  { var other: String? { get set } }
protocol ThirdDependency  { var third: UIView? { get set } }

// 3. create global storage structure that contains all possible dependencies

struct Dependencies<T>: DependencyStorage, SomeDependency, OtherDependency, ThirdDependency {
  typealias DependencyTypes = T
  var some: Int?
  var other: String?
  var third: UIView?
}

// 4. Conform to the Injectable in your own UIViewController, choose only those dependencies you need.

final class AViewController: UIViewController, Injectable {

 typealias DependencyTypes = SomeDependency & OtherDependency
 var dependencies: DependencyTypes = Dependencies<DependencyTypes>()
}


 // 5. In other controllers, before showing / switching to AViewController, inject the dependencies

override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  guard segue.identifier == "AViewController" else { return }
  let avc = segue.destination as! AViewController
  avc.dependencies.some = 0
  avc.dependencies.other = "Hi"
}

// 6. Now the dependencies are usable in your viewcontroller

 final class AViewController: UIViewController, Injectable {
   ...
   override func viewDidLoad() {
     super.viewDidLoad()

     print("Dependencies: \(dependencies.some!) \(dependencies.other!)")
   }
 }

// 7. If you forgot to set a dependency, error will be shown when your viewcontroller is loaded.

*/
