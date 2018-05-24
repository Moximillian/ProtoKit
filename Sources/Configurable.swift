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

/// Very simple dependency injection abstraction
public protocol Configurable {
  associatedtype Config
  func configure(with config: Config)
}

extension Configurable where Self: ViewController {
  /// instantiate Self from a specific Storyboard using a configuration
  public static func instantiate(storyboardName name: String, with config: Self.Config) -> Self {
    let viewController = Self.instantiate(storyboardName: name)
    viewController.configure(with: config)
    return viewController
  }
}

// Configurable protocol for simple direct dependency injection
//
//  USAGE:
//  1. Make your view controller conform to Configurable
//  2. In your controller, define your Config type, it can also be named tuple => (index: Int, title: String)
//  3. Implement configure function in your controller
//
//  final class MyViewController: UIViewController, Configurable {
//
//    typealias Config = Int
//
//    private var myValue: Int = 0
//
//    func configure(with config: Config) {
//      myValue = config
//    }
//
//    ...
//  }
//
//  4. Instantiate your controller from storyboard with configuration
//
//  let myVC = MyViewController.instantiate(config: 42)
//
