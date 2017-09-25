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
  public typealias StoryboardSegue = UIStoryboardSegue
#elseif os(macOS)
  import AppKit
  public typealias StoryboardSegue = NSStoryboardSegue
#endif

/// Protocol for Segue Identifiers
public protocol SegueHandlerType {
  associatedtype Segues: RawRepresentable
}

extension SegueHandlerType where Self: ViewController, Segues.RawValue == String {
  public func perform(segue: Segues, sender: Any? = nil) {
#if os(iOS) || os(tvOS)
    performSegue(withIdentifier: segue.rawValue, sender: sender)
#elseif os(macOS)
    performSegue(withIdentifier: .init(segue.rawValue), sender: sender)
#endif
  }

  public func identifier(for segue: StoryboardSegue) -> Segues {
#if os(iOS) || os(tvOS)
    let identifier: String? = segue.identifier
#elseif os(macOS)
    let identifier: String? = segue.identifier?.rawValue
#endif
    guard
      let i = identifier,
      let segueIdentifier = Segues(rawValue: i) else {
        fatalError("Unknown segue: \(String(describing: segue.identifier))")
    }
    return segueIdentifier
  }
}
