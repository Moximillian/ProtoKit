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

// MARK: - SwiftUI extensions for UIKit integration

#if canImport(UIKit)

@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
extension View {
  /// Convert SwiftUI view into UIHostingController
  public var uiHostingController: UIHostingController<Self> {
    let host = UIHostingController(rootView: self)
    host.view.frame.size = host.sizeThatFits(in: .zero)
    return host
  }

  /// Convert SwiftUI view into UIView
  public var uiView: UIView { self.uiHostingController.view }
}

#endif

// MARK: - SwiftUI View related extensions

@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
extension View {
  /// Type erase SwiftUI View to appease the TypeChecker gods
  public var anyView: AnyView { AnyView(self) }
}

// Extension for Rectangle
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
extension Rectangle {
  public static func using(width: CGFloat? = nil, height: CGFloat, opacity: Double = 1.0) -> some View {
    return Rectangle()
      .opacity(opacity)
      .frame(width: width, height: height)
  }
}

// Extension for GeometryProxy
@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
extension GeometryProxy {
  public var center: CGPoint { CGPoint(x: size.width / 2.0, y: size.height / 2.0) }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
extension EdgeInsets {
  /// zero insets
  public static var zero: EdgeInsets { EdgeInsets(vertical: 0, horizontal: 0) }

  /// set mirrored  insets for vertical and horizontal
  public init(vertical: CGFloat, horizontal: CGFloat) {
    self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
  }
}

// MARK: - SectionData extension to support Identifiable in SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
extension Identifiable where Self: Hashable {
  /// This is a hack and should not be used in real apps, but ok enough for quick prototyping.
  /// Provides default implementation for "id"
  public var id: Int { hashValue }
}

extension SectionData: Equatable where Item: Equatable {
  public static func == (lhs: SectionData<Item>, rhs: SectionData<Item>) -> Bool {
    return
      lhs.headerTitle == rhs.headerTitle &&
        lhs.footerTitle == rhs.footerTitle &&
        lhs.items == rhs.items
  }
}

extension SectionData: Hashable, Identifiable where Item: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(headerTitle)
    hasher.combine(footerTitle)
    items.forEach { hasher.combine($0) }
  }

  /// This is a hack and should not be used in real apps, but ok enough for quick prototyping.
  /// Provides default implementation for "id"
  public var id: Int { hashValue }
}
