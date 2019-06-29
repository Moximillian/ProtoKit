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

// MARK: - extensions

@available(iOS 13.0, *)
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

@available(iOS 13.0, macOS 10.15, *)
extension View {
  /// Type erase SwiftUI View to appease the TypeChecker gods
  public var anyView: AnyView { AnyView(self) }
}

@available(iOS 13.0, macOS 10.15, *)
extension EdgeInsets {
  /// zero insets
  public static var zero: EdgeInsets { EdgeInsets(vertical: 0, horizontal: 0) }

  /// set mirrored  insets for vertical and horizontal
  public init(vertical: Length, horizontal: Length) {
    self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
  }
}

extension Identifiable where Self: Hashable {
  /// This is a hack and should not be used in real apps, but ok enough for quick prototyping.
  /// Provides default implementation for "id"
  public var id: Int { hashValue }
}

// MARK: - SectionData

/// Abstracted data type for tables and collections
public struct SectionData<Item> {
  public var items: [Item]
  public let headerTitle: String?
  public let footerTitle: String?

  /// fancy pants convenience init
  public init(_ items: Item..., headerTitle: String? = nil, footerTitle: String? = nil) {
    self.init(items: items, headerTitle: headerTitle, footerTitle: footerTitle)
  }

  public init(items: [Item], headerTitle: String? = nil, footerTitle: String? = nil) {
    self.items = items
    self.headerTitle = headerTitle
    self.footerTitle = footerTitle
  }
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
