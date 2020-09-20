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

/*
 * This is a collection of protocols and factory objects to unify data sources across UITableView and UICollectionView
 * Inspired by Jesse Squires: https://www.skilled.io/u/swiftsummit/pushing-the-limits-of-protocol-oriented-programming
 */

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#else
  #error("Unsupported platform.")
#endif

#if canImport(UIKit)

// MARK: - Unified Collection (protocol)

/// protocol for unified Collection.
/// This conformance is already implemented in UITableView and UICollectionView
public protocol UnifiedCollection {}  // This should be kept as simple as possible to avoid implementation complexity.
extension UITableView: UnifiedCollection {}
extension UICollectionView: UnifiedCollection {}

// MARK: - Dequeable Cell (protocol)

/// protocol for unified dequeing of a cell.
/// This conformance is already implemented in UITableViewCell and UICollectionViewCell
public protocol DequeableCell {
  associatedtype Collection: UnifiedCollection
  static func dequeueReusable(in collection: Collection, for indexPath: IndexPath) -> Self
}

// MARK: - Unified Cell (protocol)

/// protocol for unified configuring of a cell. This should be conformed with the implemented cell class
public protocol UnifiedCell: DequeableCell {
  associatedtype Item
  func configure(item: Item, indexPath: IndexPath)
}

// MARK: - conformances for UnifiedCell

extension UnifiedCell where Self: UITableViewCell {
  /// provide datasource for this type of cell
  public static func dataSource(sections: [SectionData<Item>]) -> UITableViewDataSource {
    return TableDataSource<Self>(sections: sections)
  }

  /// provide datasource for this type of cell, fancy pants version
  public static func dataSource(_ variadicSections: SectionData<Item>...) -> UITableViewDataSource {
    return dataSource(sections: variadicSections)
  }
}

extension UnifiedCell where Self: UICollectionViewCell {
  /// provide datasource for this type of cell
  public static func dataSource<Title: TitleType>(titleType: Title.Type,
                                                  sections: [SectionData<Item>])
                                                  -> UICollectionViewDataSource where Item == Title.Item {
    return CollectionDataSource<Self, Title>(sections: sections)
  }

  /// provide datasource for this type of cell, fancy pants version
  public static func dataSource<Title: TitleType>(titleType: Title.Type,
                                                  _ variadicSections: SectionData<Item>...)
                                                  -> UICollectionViewDataSource where Item == Title.Item {
    return dataSource(titleType: titleType, sections: variadicSections)
  }
}

// MARK: - Unified Title  (protocol)

/// protocol for unified UICollectionReusableView. This should be conformed with the implemented cell class
public protocol UnifiedTitle {
  associatedtype Item
  func configure(item: Item, kind: String, indexPath: IndexPath)
}

// MARK: - typealiases for TableCellType, CollectionCellType and TitleType

public typealias TableCellType = UITableViewCell & UnifiedCell
public typealias CollectionCellType = UICollectionViewCell & UnifiedCell
public typealias TitleType = UICollectionReusableView & UnifiedTitle

// MARK: - Unified DataSource (parent class)

/// Factory for creating datasources
private class UnifiedDataSource<Cell: UnifiedCell>: NSObject {

  private var sections: [SectionData<Cell.Item>]

  init(sections: [SectionData<Cell.Item>]) {
    self.sections = sections
  }

  // Common helpers
  fileprivate var numberOfSections: Int {
    get { sections.count }
  }
  fileprivate func item(at indexPath: IndexPath) -> Cell.Item {
    return sections[indexPath.section].items[indexPath.row]
  }
  fileprivate func numberOfItems(in section: Int) -> Int { return sections[section].items.count }
  fileprivate func headerTitle(in section: Int) -> String? { return sections[section].headerTitle }
  fileprivate func footerTitle(in section: Int) -> String? { return sections[section].footerTitle }
  // DISABLED this function due to compiler crash in Xcode 12
  //  fileprivate func cell(for collection: Cell.Collection, at indexPath: IndexPath) -> Cell {
  //    let cell = Cell.dequeueReusable(in: collection, for: indexPath)
  //    cell.configure(item: item(at: indexPath), indexPath: indexPath)
  //    return cell
  //  }
}

// MARK: - Table Data Source, inheriting from Unified Data Source

/// UITableViewDataSource implementation for UnifiedDataSource
fileprivate final class TableDataSource<Cell: TableCellType>: UnifiedDataSource<Cell>, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return numberOfSections
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfItems(in: section)
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return headerTitle(in: section)
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return footerTitle(in: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    return cell(for: tableView, at: indexPath)
    let cell = Cell.dequeueReusable(in: tableView, for: indexPath)
    cell.configure(item: item(at: indexPath), indexPath: indexPath)
    return cell
  }
}

// MARK: - Collection Data Source, inheriting from Unified Data Source

/// UICollectionViewDataSource implementation for UnifiedDataSource
fileprivate final class CollectionDataSource<Cell: CollectionCellType, Title: TitleType>:
                                            UnifiedDataSource<Cell>, UICollectionViewDataSource
                                            where Cell.Item == Title.Item {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return numberOfSections
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfItems(in: section)
  }

  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    let view = Title.dequeueReusable(in: collectionView, ofKind: kind, for: indexPath)
    view.configure(item: item(at: indexPath), kind: kind, indexPath: indexPath)
    return view
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//    return cell(for: collectionView, at: indexPath)
    let cell = Cell.dequeueReusable(in: collectionView, for: indexPath)
    cell.configure(item: item(at: indexPath), indexPath: indexPath)
    return cell
  }
}

#endif

/*
 //  -------- USAGE ----------

 // 1. create your cell (e.g. MyCell) and conform to UnifiedCell by providing configure -method.
 // In the method, provide your actual class/struct type of your Items (here is MyData Struct as simple example).

 struct MyData {
   var title: String
   var value: Int
 }


 final class MyCell: UITableViewCell, UnifiedCell {

   // ...

   public func configure(item: MyData, collection: UITableView, indexPath: IndexPath) {
     // ...
     textLabel?.text = item.title
     detailTextLabel?.text = "\(item.value)"
     // ...
   }
 }

 // 2. In Interface Builder, set your cell identifier as your cell class name e.g. "MyCell" in this example


 // 3. Hook up your data so that you have a single value or array of Items that use same type
 // as configure function above

 let items = [MyData(title: "first", value: 5), MyData(title: "second", value: 1)]


 // 4. Create your SectionData by using one or an array of Item values, see above.

 let sectionData = SectionData(items: items, headerTitle: "hello", footerTitle: nil)


 // 5. create data source by calling the (static) datasource method on your cell, provide your data to it.
 //    In your viewmodel or viewcontroller, retain the reference to the datasource

 let dataSource: UITableViewDataSource = MyCell.dataSource(sectionData)

 // 6. provide the datasource to your table view (or collectionview)

 tableView.dataSource = dataSource  // remember to keep reference to the dataSource in your viewcontroller

 */
