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

import Foundation

extension NSObject {
  func store(associatedObject: Any) {
    // store the container so that it can be called later, we do not need to explicitly retrieve it.

    #if canImport(UIKit)
    accessibilityElements = accessibilityElements ?? []
    accessibilityElements!.append(associatedObject)

    #elseif canImport(AppKit)
    var associatedObjectStore = objc_getAssociatedObject(self,
                                                         Unmanaged.passUnretained(self).toOpaque()) as? [Any] ?? []
    associatedObjectStore.append(associatedObject)
    objc_setAssociatedObject(self,
                             Unmanaged.passUnretained(self).toOpaque(),
                             associatedObjectStore,
                             .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    #else
      #error("Unsupported platform.")
    #endif
  }
}
