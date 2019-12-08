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

import SwiftUI

/// Swift UI View that draws a Line.
/// To change color provide .accentColor()
///
/// - Parameter width: The width of the line
///
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
public struct Line: View {
  private let width: CGFloat

#if os(iOS)
  public init(width: CGFloat = UIScreen.main.bounds.width) {
    self.width = width
  }
#else
  public init(width: CGFloat = 0) {
    self.width = width
  }
#endif

  public var body: some View {
    Rectangle()
      .frame(width: self.width, height: 1)
      .foregroundColor(.accentColor)
  }
}

// MARK: - Debug

#if DEBUG
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
struct Line_Previews : PreviewProvider {
    static var previews: some View {
      return Line(width: 200)
    }
}
#endif
