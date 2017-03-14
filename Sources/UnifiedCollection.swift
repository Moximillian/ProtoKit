//
//  Created by Mox Soini
//  https://www.linkedin.com/in/moxsoini
//
//  GitHub
//  https://github.com/moximillian/ProtoKit
//
//  License
//  Copyright © 2015 Mox Soini
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

/*
 * This is a collection of protocols and factory objects to unify data sources across UITableView and UICollectionView
 * Inspired by Jesse Squires: https://www.skilled.io/u/swiftsummit/pushing-the-limits-of-protocol-oriented-programming
 */


import UIKit

// MARK: - Unified Collection

/// protocol for unified UITableView and UICollectionView
public protocol UnifiedCollectionType {
  func dequeueReusableCell<T: UnifiedCellType>(indexPath: IndexPath) -> T
}

/// UICollectionView implementation of UnifiedCollectionType
extension UICollectionView: UnifiedCollectionType {

  public func dequeueReusableCell<T: UnifiedCellType>(indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue collectionview cell with identifier: \(T.self)")
    }
    return cell
  }

  public func dequeueReusableSupplementaryView<T: UnifiedTitleType>(ofKind kind: String, for indexPath: IndexPath) -> T {
    guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue reusable supplementary view with identifier: \(T.self)")
    }
    return view
  }
}

/// UITableView implementation of UnifiedCollectionType
extension UITableView: UnifiedCollectionType {

  public func dequeueReusableCell<T: UnifiedCellType>(indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue tableview cell with identifier: \(T.self)")
    }
    return cell
  }
}

// MARK: - Unified Cell

// Ideally UnifiedCellCollectionable should have been just "extension UITableCell where Self: UnifiedCellType {}",
// but this is not currently possible. Recheck if/when existentials are available in Swift 4.

/// protocol for generic collection in UnifiedCells
public protocol UnifiedCellCollectionable {
  associatedtype Collection: UnifiedCollectionType
}

extension UITableViewCell: UnifiedCellCollectionable {
  public typealias Collection = UITableView
}

extension UICollectionViewCell: UnifiedCellCollectionable {
  public typealias Collection = UICollectionView
}

/// protocol for unified UITableViewCell and UICollectionViewCell. This should be conformed with the implemented cell class
public protocol UnifiedCellType: UnifiedCellCollectionable {
  associatedtype Item
  func configure(item: Item, collection: Collection, indexPath: IndexPath)
}

/// protocol for unified UICollectionReusableView. This should be conformed with the implemented cell class
public protocol UnifiedTitleType {
  associatedtype Item
  func configure(item: Item, collection: UICollectionView, kind: String, indexPath: IndexPath)
}


// MARK: - Section Data (source data container)

/// Protocol for section data
public protocol SectionDataType {
  associatedtype Item
  var items: [Item] { get set }
  var headerTitle: String? { get }
  var footerTitle: String? { get }
}

/// Factory valuetype for section protocol
public struct SectionData<Item>: SectionDataType {
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

// MARK: - Unified Datasource Factory

/// Protocol for data source factories
public protocol DataSourceFactoryType {
  associatedtype Cell: UnifiedCellType
  associatedtype Section: SectionDataType
  typealias Item = Cell.Item
  typealias Collection = Cell.Collection

  var sections: [Section] { get }
  var cellType: Cell.Type { get }
}

extension DataSourceFactoryType where Cell.Item == Section.Item {

  // Common implementations for factories

  func item(at indexPath: IndexPath) -> Item {
    return sections[indexPath.section].items[indexPath.row]
  }

  /// Generate cells based on the correct cell type
  func cell(for collection: Collection, indexPath: IndexPath) -> Cell {
    let item = self.item(at: indexPath)
    let cell: Cell = collection.dequeueReusableCell(indexPath: indexPath)
    cell.configure(item: item, collection: collection, indexPath: indexPath)
    return cell
  }

  // MARK: - DataSourceFactoryType implementations for common functions

  func numberOfSections() -> Int {
    return sections.count
  }

  func numberOfItems(_ section: Int) -> Int {
    return sections[section].items.count
  }
}

/// Factory for creating UITableViewDataSource
public struct TableDataSourceFactory<Cell: UnifiedCellType, Section: SectionDataType>: DataSourceFactoryType
where Cell.Item == Section.Item, Cell.Collection == UITableView {

  public var sections: [Section]
  public var cellType: Cell.Type
  private var source: UnifiedDataSource = UnifiedDataSource()

  /// fancy pants convenience init for UITableView
  public init(cell cellType: Cell.Type, _ sections: Section...) {
    self.init(cell: cellType, sections: sections)
  }

  /// Init for UITableView
  public init(cell cellType: Cell.Type, sections: [Section]) {
    self.sections = sections
    self.cellType = cellType
  }

  /// TableViewDataSource from UnifiedDataSource
  public var tableViewDataSource: UITableViewDataSource {

    // store functions as closures in UnifiedDataSource
    source.numberOfSections = numberOfSections
    source.numberOfItems = numberOfItems
    source.headerTitle = headerTitle
    source.footerTitle = footerTitle
    source.cellForTable = cellForTable
    return source
  }

  // MARK: - DataSourceFactoryType implementations for UITableView

  private func headerTitle(_ section: Int) -> String? {
    return sections[section].headerTitle
  }

  private func footerTitle(_ section: Int) -> String? {
    return sections[section].footerTitle
  }

  private func cellForTable(collection: UITableView, indexPath: IndexPath) -> UITableViewCell {
    return cell(for: collection, indexPath: indexPath) as! UITableViewCell
  }
}


/// Factory for creating UICollectionViewDataSource
public struct CollectionDataSourceFactory<Cell: UnifiedCellType, Section: SectionDataType, Title: UnifiedTitleType>: DataSourceFactoryType
where Cell.Item == Section.Item, Cell.Item == Title.Item, Cell.Collection == UICollectionView {

  public var sections: [Section]
  public var cellType: Cell.Type
  private var titleType: Title.Type
  private var source: UnifiedDataSource = UnifiedDataSource()

  /// fancy pants convenience init for UICollectionView
  public init(cell cellType: Cell.Type, title titleType: Title.Type, _ sections: Section...) {
    self.init(cell: cellType, title: titleType, sections: sections)
  }

  /// Init for UICollectionView
  public init(cell cellType: Cell.Type, title titleType: Title.Type, sections: [Section]) {
    self.sections = sections
    self.cellType = cellType
    self.titleType = titleType
  }

  /// CollectionViewSource from UnifiedDataSource
  public var collectionViewDataSource: UICollectionViewDataSource {

    // store functions as closures in UnifiedDataSource
    source.numberOfSections = numberOfSections
    source.numberOfItems = numberOfItems
    source.cellForCollection = cellForCollection
    source.titleForCollection = titleForCollection
    return source
  }

  // MARK: DataSourceFactoryType implementations for UICollectionView

  private func cellForCollection(collection: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    return cell(for: collection, indexPath: indexPath) as! UICollectionViewCell
  }

  private func titleForCollection(collection: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
    let item = self.item(at: indexPath)
    let view: Title = collection.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
    view.configure(item: item, collection: collection, kind: kind, indexPath: indexPath)
    return view as! UICollectionReusableView
  }
}


// MARK: - Unified Datasource (internal implementation)

/// Unified Data Source class with stored closures, which are mapped to native data source APIs
fileprivate final class UnifiedDataSource: NSObject {
  typealias NumberOfSectionsType = () -> Int
  typealias NumberOfItemsType = (Int) -> Int
  typealias TitleType = (Int) -> String?
  typealias TableType = (UITableView, IndexPath) -> UITableViewCell
  typealias CollectionType = (UICollectionView, IndexPath) -> UICollectionViewCell
  typealias CollectionTitleType = (UICollectionView, String, IndexPath) -> UICollectionReusableView

  // Objective-C does not allow for class level generics, so store as native closures.
  var numberOfSections: NumberOfSectionsType?
  var numberOfItems: NumberOfItemsType?
  var headerTitle: TitleType?
  var footerTitle: TitleType?
  var cellForTable: TableType?
  var cellForCollection: CollectionType?
  var titleForCollection: CollectionTitleType?
}

/// UITableViewDataSource implementation of UnifiedDataSourceType
extension UnifiedDataSource: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return self.numberOfSections!()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.numberOfItems!(section)
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.headerTitle!(section)
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return self.footerTitle!(section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return self.cellForTable!(tableView, indexPath)
  }
}

/// UICollectionViewDataSource implementation of UnifiedDataSourceType
extension UnifiedDataSource: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return self.numberOfSections!()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.numberOfItems!(section)
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    return self.titleForCollection!(collectionView, kind, indexPath)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return self.cellForCollection!(collectionView, indexPath)
  }
}




/*
 //  -------- USAGE ----------

 // 1. create your cell (e.g. MyCell) and conform to UnifiedCellType by providing configure -method. In the method, provide your actual class/struct type of your Items (here is MyData Struct as simple example).

 struct MyData {
 var title: String
 var value: Int
 }


 final class MyCell: UITableViewCell, UnifiedCellType {

 // ...

 public func configure(item: MyData, collection: UITableView, indexPath: IndexPath) {
 // ...
 textLabel?.text = item.title
 detailTextLabel?.text = String(item.value)
 // ...
 }
 }

 // 2. Hook up your data so that you have a single value or array of Items that use same type as configure function above

 let items = [MyData(title: "first", value: 5), MyData(title: "second", value: 1)]


 // 3. In your viewcontroller's viewDidLoad method or similar, create your SectionData by using one or an array of Item values, see above.

 let sectionData = SectionData(items: items, headerTitle: "hello", footerTitle: nil)


 // 3. create factory, provide your cell type to it. Also, in Interface Builder, set your cell identifier as your cell class name e.g. "MyCell" in this example

 let factory = TableDataSourceFactory(cell: MyCell.self, sectionData)


 // 4. provide the datasource to your table view (or collectionview)

 tableView.dataSource = factory.tableViewDataSource
 
 */
