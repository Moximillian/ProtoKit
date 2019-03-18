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
  public typealias StoryboardSegue = UIStoryboardSegue
#elseif canImport(AppKit)
  import AppKit
  public typealias StoryboardSegue = NSStoryboardSegue
#else
  #error("Unsupported platform.")
#endif

/// Protocol for Segue Identifiers
public protocol SegueHandlerType: ViewController {
  associatedtype Segues: RawRepresentable where Segues.RawValue == String
}

extension SegueHandlerType {
  public func perform(segue: Segues, sender: Any? = nil) {
    performSegue(withIdentifier: segue.rawValue, sender: sender)
  }

  public func identifier(for segue: StoryboardSegue) -> Segues {
    guard
      let rawValue = segue.identifier,
      let segueIdentifier = Segues(rawValue: rawValue) else {
        fatalError("Unknown segue: \(segue.identifier ?? "")")
    }
    return segueIdentifier
  }
}
