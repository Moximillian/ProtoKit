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

/// Swift UI View that animates a circular progress graphic inside frame provided for this view.
/// Animation always starts from zero.
/// To change color provide .accentColor()
///
/// - Parameter progress: The target progress value where animation should end (between 0...1.0)
/// - Parameter lineWidth: The width of the stroke in the circle
/// - Parameter strokeBackgroundColor: The color of the circle stroke background
/// - Parameter fillColor: The color of the circle background fill
///
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
public struct CircleShape: View {
  private let progress: CGFloat
  private let lineWidth: CGFloat
  private let strokeBackgroundColor: Color
  private let fillColor: Color

  public init(progress: CGFloat, lineWidth: CGFloat = 2.0, strokeBackgroundColor: Color = .clear, fillColor: Color = .clear) {
    self.progress = max(0, min(1.0, progress)) // lock into range 0...1.0
    self.lineWidth = lineWidth
    self.strokeBackgroundColor = strokeBackgroundColor
    self.fillColor = fillColor
  }

  public var body: some View {
    ZStack {
      GeometryReader { geometry in
        Circle()
          .foregroundColor(self.fillColor)

        StrokeCircleBackground(lineWidth: self.lineWidth)
          .stroke(self.strokeBackgroundColor, lineWidth: self.lineWidth)

        StrokeCircle(lineWidth: self.lineWidth, progress: self.progress)
          .transform(.init(rotationAngle: CGFloat(-.pi / Double(2.0))))
          .transform(.init(translationX: geometry.center.x, y: geometry.center.y))
          .stroke(Color.accentColor, style: .init(lineWidth: self.lineWidth, lineCap: .round))
      }
    }
  }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
fileprivate struct StrokeCircle: Shape {
  let lineWidth: CGFloat
  var progress: CGFloat

  func path(in rect: CGRect) -> Path {
    return Path {
      $0.addArc(center: .zero,
                radius: rect.radius(self.lineWidth),
                startAngle: .init(degrees: 0),
                endAngle: Angle(degrees: 360 * Double(progress)),
                clockwise: false)
    }
  }

  var animatableData: CGFloat {
    get { return progress }
    set { progress = newValue }
  }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
fileprivate struct StrokeCircleBackground: Shape {
  let lineWidth: CGFloat

  func path(in rect: CGRect) -> Path {
    return Path {
      $0.addArc(center: rect.mid,
                radius: rect.radius(self.lineWidth),
                startAngle: .init(degrees: 0),
                endAngle: .init(degrees: 360),
                clockwise: false)
    }
  }
}

// MARK: - Debug

#if DEBUG
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
struct CircleShape_Previews : PreviewProvider {

  static var previews: some View {
    TestCircleShape()
      .frame(width: 300, height: 300)
  }

  fileprivate struct TestCircleShape: View {
    @State private var progress: CGFloat = 0

    var body: some View {
      CircleShape(progress: progress, lineWidth: 15, strokeBackgroundColor: .init(white: 0.8), fillColor: .init(white: 0.9))
        .onAppear {
          withAnimation(Animation.easeOut(duration: 1)) {
            self.progress = 0.8
          }
        }
    }
  }
}
#endif
