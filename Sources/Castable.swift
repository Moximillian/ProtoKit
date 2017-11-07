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

import Foundation

public protocol Castable {}

extension Castable {
  /// Try to cast an object to another type, or describe failure
  public func cast<T>(function: String = #function, file: String = #file) -> T {
    guard let object = self as? T else { fatalError("Cannot change \(String(describing: self)) to \(String(describing: T.self)) in \(function) at \(file)") }
    return object
  }
}

extension NSObject: Castable {}
extension Optional: Castable {}

infix operator <*: CastingPrecedence

/// Try to cast an object to another type, or describe failure
public func <* <T>(lhs: Castable, rhs: T.Type) -> T {
  return lhs.cast() as T
}


