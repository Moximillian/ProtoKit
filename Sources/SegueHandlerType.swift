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

/// Protocol for Segue Identifiers
public protocol SegueHandlerType {
  associatedtype Segues: RawRepresentable
}

extension SegueHandlerType where Self: UIViewController, Segues.RawValue == String {
  public func perform(segue: Segues, sender: Any? = nil) {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }

  public func identifier(for segue: UIStoryboardSegue) -> Segues {
    guard
      let identifier = segue.identifier,
      let segueIdentifier = Segues(rawValue: identifier) else {
        fatalError("Unknown segue: " + String(describing: segue.identifier))
    }
    return segueIdentifier
  }
}
