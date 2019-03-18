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

import XCTest
@testable import ProtoKit

class SelfPresentableTests: XCTestCase {

  class TestClass: SelfPresentable {}

  func testAsSelf() {
    XCTAssertEqual(TestClass.identifier, "TestClass")
  }

}
