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

import XCTest
@testable import ProtoKit

extension TypedNotification {
  static var note1: TypedNotification<Int> { return .init(title: "myNotification1") }
  static var note2: TypedNotification<String> { return .init(title: "myNotification2") }
}

@available(iOS 13.0, macOS 10.15, *)
class NotificationServiceTests: XCTestCase {
  let notificationService = NotificationService()
  var result1: Int = -1
  var result2: String = ""

  override func setUp() {
    notificationService.listen(to: .note1, using: { self.result1 = $0 } )
    notificationService.listen(to: .note2, using: { self.result2 = $0 } )
  }

  func testNotificationService1() {
    XCTAssertEqual(result1, -1)
    NotificationService.post(.note1, value: 42)
    XCTAssertEqual(result1, 42)
  }

  func testNotificationService2() {
    XCTAssertEqual(result2, "")
    NotificationService.post(.note2, value: "Don't panic")
    XCTAssertEqual(result2, "Don't panic")
  }

}
