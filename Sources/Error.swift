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

/// Custom Error type
public struct SourcedError: Error {
  public let source, reason: String
  public init(_ reason: String, source: String = #function, file: String = #file, line: Int = #line) {
    self.reason = reason
    self.source = "\(source):\(file):\(line)"
  }
}
