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

class UnifiedCollectionTests: XCTestCase {
  struct TestData {
    var value: Int
  }

  final class TestCell: UITableViewCell, UnifiedCell {
    func configure(item: TestData, indexPath: IndexPath) {
      textLabel?.text = "\(item.value)"
    }
  }

  let section1 = SectionData(items:
    [TestData(value: 1), TestData(value: 2), TestData(value: 3), TestData(value: 4), TestData(value: 5)]
  )
  let section2 = SectionData(items:
    [TestData(value: 6), TestData(value: 7), TestData(value: 8), TestData(value: 9), TestData(value: 10)],
                             headerTitle: "header2",
                             footerTitle: "footer2")
  var dataSource: UITableViewDataSource!
  let table = UITableView().then {
    TestCell.register(to: $0)
  }

  override func setUp() {
    dataSource = TestCell.dataSource(sections: [section1, section2])
    table.dataSource = dataSource
  }

  func testTable() {
    XCTAssertNotNil(table)
    XCTAssertEqual(table.numberOfSections, 2)
    XCTAssertEqual(table.numberOfRows(inSection: 0), section1.items.count)
    XCTAssertEqual(table.numberOfRows(inSection: 1), section2.items.count)
  }

  func testSection1() {
    let section = 0
    var cell: UITableViewCell!
    var headerTitle: String?
    self.measure {
      cell = dataSource.tableView(table, cellForRowAt: IndexPath(row: 0, section: section))
      headerTitle = dataSource.tableView!(table, titleForHeaderInSection: section)
    }
    XCTAssertNotNil(cell)
    XCTAssertNotNil(cell.textLabel?.text)
    XCTAssertEqual(cell.textLabel!.text, "\(section1.items[0].value)")
    XCTAssertNil(headerTitle)
  }

  func testSection2() {
    let section = 1
    var cell: UITableViewCell!
    var headerTitle: String?
    var footerTitle: String?
    self.measure {
      cell = dataSource.tableView(table, cellForRowAt: IndexPath(row: 2, section: section))
      headerTitle = dataSource.tableView!(table, titleForHeaderInSection: section)
      footerTitle = dataSource.tableView!(table, titleForFooterInSection: section)
    }
    XCTAssertNotNil(cell)
    XCTAssertNotNil(cell.textLabel?.text)
    XCTAssertEqual(cell.textLabel!.text, "\(section2.items[2].value)")
    XCTAssertNotNil(headerTitle)
    XCTAssertEqual(headerTitle, "\(section2.headerTitle!)")
    XCTAssertNotNil(footerTitle)
    XCTAssertEqual(footerTitle, "\(section2.footerTitle!)")
  }
}
