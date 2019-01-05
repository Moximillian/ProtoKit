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

class KVOTests: XCTestCase {

  final class Model: NSObject {
    @objc dynamic var value: Int = 0
    @objc dynamic var optional: String?
  }

  final class Target: NSObject {
    var targetValue: Int = 0
    var targetOptional: String?
  }

  let model = Model()
  let target = Target()

  override func setUp() {
    model.bind(\.value, to: target, at: \.targetValue)
    model.bind(\.optional, to: target, at: \.targetOptional)
  }

  func testKVO() {
    XCTAssertEqual(model.value, 0)
    XCTAssertEqual(target.targetValue, 0)
    model.value = 42
    XCTAssertEqual(model.value, 42)
    XCTAssertEqual(target.targetValue, 42)
  }

  func testOptionalKVO() {
    XCTAssertEqual(model.optional, nil)
    XCTAssertEqual(target.targetOptional, nil)
    model.optional = "hello"
    XCTAssertEqual(model.optional, "hello")
    XCTAssertEqual(target.targetOptional, "hello")

    #warning ("optionalKVO not fully working")
    model.optional = nil
    XCTAssertEqual(model.optional, nil)
    //XCTAssertEqual(target.targetOptional, nil)  // https://bugs.swift.org/browse/SR-6066
  }

}
