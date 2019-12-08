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

/// Swift UI View that animates a numeric progress as Text inside frame provided for this view.
/// Animation always starts from zero.
/// To change color provide .accentColor()
///
/// - Parameter value: The target value where animation should end
/// - Parameter weight: The font weight to use when displaying this text.
/// - Parameter design: The font design to use when displaying this text.
///
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
public struct ProgressText: View {
  private let value: CGFloat
  private let weight: Font.Weight
  private let design: Font.Design

  public init(value: CGFloat = 0, weight: Font.Weight = .regular, design: Font.Design = .default) {
    self.value = value
    self.weight = weight
    self.design = design
  }

  public var body: some View {
    GeometryReader { geometry in
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: geometry.size.width, height: geometry.size.height)
        .modifier(AnimatableProgress(value: self.value, weight: self.weight, design: self.design))
    }
  }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
fileprivate struct AnimatableProgress: AnimatableModifier {
  var value: CGFloat
  let weight: Font.Weight
  let design: Font.Design

  func body(content: Content) -> some View {
    content
      .overlay(
        Text(formatValue(self.value))
        .resizableHeightFont(weight: weight, design: design)
        .foregroundColor(.accentColor)
      )
  }

  func formatValue(_ value: CGFloat) -> String {
    return "\(value, .compact)"
  }

  var animatableData: CGFloat {
    get { value }
    set { value = newValue }
  }
}

// MARK: - Debug

#if DEBUG
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
struct ProgressText_Previews : PreviewProvider {

  static var previews: some View {
    TestAnimatedLabel()
      .frame(width: 300, height: 100)
      .border(Color.gray.opacity(0.2))
  }

  fileprivate struct TestAnimatedLabel: View {
    @State private var value: CGFloat = 0

    var body: some View {
      return ProgressText(value: value, weight: .thin)
        .onAppear {
          withAnimation(Animation.easeOut(duration: 1)) {
            self.value = 100
          }
        }
    }
  }
}
#endif
