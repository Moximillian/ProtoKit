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

/// Injectable protocol
public protocol Injectable {
  associatedtype T

  // fill in the parameter name during implementation
  func inject(_: T)
  func assertDependencies()
}

