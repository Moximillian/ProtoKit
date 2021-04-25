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

}
// Default conformances of SelfPresentable for ViewControllers and Views
extension UnifiedViewController: SelfPresentable {}
extension UnifiedView: SelfPresentable {}
