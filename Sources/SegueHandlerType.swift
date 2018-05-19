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
  public typealias StoryboardSegue = UIStoryboardSegue
#elseif canImport(AppKit)
  import AppKit
  public typealias StoryboardSegue = NSStoryboardSegue
#else
  #if swift (>=4.2)
    #error("Unsupported platform.")
  #endif
#endif

/// Protocol for Segue Identifiers
public protocol SegueHandlerType {
  associatedtype Segues: RawRepresentable where Segues.RawValue == String
}

extension SegueHandlerType where Self: ViewController {
  public func perform(segue: Segues, sender: Any? = nil) {
#if canImport(UIKit)
    performSegue(withIdentifier: segue.rawValue, sender: sender)
#elseif canImport(AppKit)
    performSegue(withIdentifier: .init(segue.rawValue), sender: sender)
#endif
  }

  public func identifier(for segue: StoryboardSegue) -> Segues {
#if canImport(UIKit)
    let identifier: String? = segue.identifier
#elseif canImport(AppKit)
    let identifier: String? = segue.identifier?.rawValue
#endif
    guard
      let rawValue = identifier,
      let segueIdentifier = Segues(rawValue: rawValue) else {
        fatalError("Unknown segue: \(String(describing: segue.identifier))")
    }
    return segueIdentifier
  }
}
