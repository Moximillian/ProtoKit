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

/// Very simple dependency injection abstraction
public protocol Configurable: UnifiedViewController {
  associatedtype Config
  func configure(with config: Config)
}

extension Configurable {
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
//  2. In your controller, decide your Config type, it could also be named tuple => (index: Int, title: String)
//  3. Implement configure function in your controller, using your chosen concrete type for Config
//
//  final class MyViewController: UIViewController, Configurable {
//
//    func configure(with config: Int) {
//      myValue = config
//    }
//
//    private var myValue: Int = 0
//
//
//    ...
//  }
//
//  4. Instantiate your controller from storyboard with configuration
//
//  let myVC = MyViewController.instantiate(with: 42)
//
