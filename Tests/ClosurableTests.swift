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

protocol Target: NSObject, Closurable {
  var target: AnyObject? { get set }
  var action: Selector? { get set }
}

extension Target {
  func addTarget(closure: @escaping (Self) -> Void) {
    let container = getContainer(for: closure)
    target = container
    action = container.action
  }
}

class ClosurableTests: XCTestCase {

  class Targetable: NSObject, Target {
    var target: AnyObject?
    var action: Selector?
    var result: String?
  }

  class SubTargetable: Targetable {
    var result2: Int?
  }

  let targetable = Targetable()
  let subtargetable = SubTargetable()

  override func setUp() {
    targetable.result = nil
    subtargetable.result = nil
    subtargetable.result2 = nil

    targetable.addTarget { trg in
      trg.result = "called"
    }

    subtargetable.addTarget { sub in
      sub.result2 = 2
    }
  }

  func testClosurable1() {
    XCTAssertNil(targetable.result)
    _ = targetable.target!.perform(targetable.action)
    XCTAssertEqual(targetable.result!, "called")
  }

  func testClosurable2() {
    XCTAssertNil(subtargetable.result)
    XCTAssertNil(subtargetable.result2)
    _ = subtargetable.target!.perform(subtargetable.action)
    XCTAssertEqual(subtargetable.result2!, 2)
  }

}
