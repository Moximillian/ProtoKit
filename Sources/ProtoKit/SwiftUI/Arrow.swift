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

/// Swift UI View that draws an arrow inside the frame provided for this view
/// To change color provide .accentColor()
///
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
public struct Arrow: View {
  public init() {}

  public var body: some View {
    GeometryReader { geometry in
      Path {
        let height = min(geometry.size.width * 2, geometry.size.height)
        let width = height * 0.5
        $0.addLines([
          .zero,
          CGPoint(x: width, y: width),
          CGPoint(x: 0, y: height)
        ])
      }
      .stroke(Color.accentColor, lineWidth: 2)
      .aspectRatio(1, contentMode: .fit)
    }
  }
}

// MARK: - Debug

#if DEBUG
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
struct Arrow_Previews : PreviewProvider {
  static var previews: some View {
    return Arrow()
      .frame(width: 40, height: 40)
  }
}
#endif
