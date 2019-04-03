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
#elseif canImport(AppKit)
import AppKit
#else
#error("Unsupported platform.")
#endif

/// Protocol to workaround the lack of Self in classes
public protocol SelfPresentable {}

extension SelfPresentable {

  /// Identifier derived from the name of the class
  public static var identifier: String { return String(describing: self) }

  #if swift(<5.1)
  /// Cast an object to Self or show error message
  public static func asSelf(object: Any?, _ errorMessage: String) -> Self {
    guard let object = object as? Self else { fatalError(errorMessage) }
    return object
  }
  #endif
}
// Default conformances of SelfPresentable for ViewControllers and Views
extension ViewController: SelfPresentable {}
extension View: SelfPresentable {}
