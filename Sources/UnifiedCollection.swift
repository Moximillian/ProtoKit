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


// MARK: - Section data (source data container)
public protocol SectionType {
  associatedtype Item

  var items: [Item] { get }
  var headerTitle: String? { get }
  var footerTitle: String? { get }
}

/// Factory valuetype for section protocol
public struct SectionData<Item>: SectionType {
  public var items: [Item]
  private(set) public var headerTitle: String?
  private(set) public var footerTitle: String?

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
  associatedtype Collection
  associatedtype Cell: UnifiedCellType where Cell.Collection == Collection
  associatedtype Section: SectionType where Section.Item == Cell.Item

  init(cell cellType: Cell.Type, sections: [Section])
  var sections: [Section] { get }
}

extension DataSourceFactoryType {

  // Common implementations for factories

  fileprivate func item(at indexPath: IndexPath) -> Cell.Item {
    return sections[indexPath.section].items[indexPath.row]
  }

  /// Generate cells based on the correct cell type
  fileprivate func cell(for collection: Collection, indexPath: IndexPath) -> Cell {
    let item = self.item(at: indexPath)
    let cell: Cell = collection.dequeueReusableCell(indexPath: indexPath)
    cell.configure(item: item, collection: collection, indexPath: indexPath)
    return cell
  }

  // MARK: - DataSourceFactoryType implementations for common functions

  fileprivate func numberOfSections() -> Int {
    return sections.count
  }

  fileprivate func numberOfItems(_ section: Int) -> Int {
    return sections[section].items.count
  }
}

/// Factory for creating UITableViewDataSource
public final class TableDataSourceFactory<Cell: UITableViewCell & UnifiedCellType, Section: SectionType>: DataSourceFactoryType
  where Section.Item == Cell.Item {
  public typealias Collection = UITableView

  private(set) public var sections: [Section]

  /// fancy pants convenience init for UITableView
  public convenience init(cell cellType: Cell.Type, _ sections: Section...) {
    self.init(cell: cellType, sections: sections)
  }

  /// Init for UITableView
  public init(cell cellType: Cell.Type, sections: [Section]) {
    self.sections = sections
  }

  /// TableViewDataSource from UnifiedDataSource
  public var tableViewDataSource: UITableViewDataSource {
    let source = UnifiedDataSource(factory: self)
    // store functions as closures in UnifiedDataSource. Cannot assign functions directly due to retain cycles
    source.numberOfSections = { [unowned self] in return self.numberOfSections() }
    source.numberOfItems = { [unowned self] in return self.numberOfItems($0) }
    source.headerTitle = { [unowned self] in return self.headerTitle($0) }
    source.footerTitle = { [unowned self] in return self.footerTitle($0) }
    source.cellForTable = { [unowned self] in return self.cellForTable(collection: $0, indexPath: $1) }
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
    return cell(for: collection, indexPath: indexPath)
  }
}


/// Factory for creating UICollectionViewDataSource
public final class CollectionDataSourceFactory<Cell: UICollectionViewCell & UnifiedCellType, Title: UICollectionReusableView & UnifiedTitleType, Section: SectionType>: DataSourceFactoryType
where Cell.Item == Title.Item, Section.Item == Cell.Item  {
  public typealias Collection = UICollectionView

  private(set) public var sections: [Section]

  /// fancy pants convenience init for UICollectionView
  public convenience init(cell cellType: Cell.Type, title titleType: Title.Type, _ sections: Section...) {
    self.init(cell: cellType, title: titleType, sections: sections)
  }

  /// Init for UICollectionView
  public init(cell cellType: Cell.Type, title titleType: Title.Type, sections: [Section]) {
    self.sections = sections
  }

  /// Required Init
  public init(cell cellType: Cell.Type, sections: [Section]) {
    self.sections = sections
  }

  /// CollectionViewSource from UnifiedDataSource
  public var collectionViewDataSource: UICollectionViewDataSource {
    let source = UnifiedDataSource(factory: self)
    // store functions as closures in UnifiedDataSource. Cannot assign functions directly due to retain cycles
    source.numberOfSections = { [unowned self] in return self.numberOfSections() }
    source.numberOfItems = { [unowned self] in return self.numberOfItems($0) }
    source.cellForCollection = { [unowned self] in return self.cellForCollection(collection: $0, indexPath: $1) }
    source.titleForCollection = { [unowned self] in return self.titleForCollection(collection: $0, kind: $1, indexPath: $2) }
    return source
  }

  // MARK: DataSourceFactoryType implementations for UICollectionView

  private func cellForCollection(collection: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
    return cell(for: collection, indexPath: indexPath)
  }

  private func titleForCollection(collection: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
    let item = self.item(at: indexPath)
    let view: Title = collection.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
    view.configure(item: item, collection: collection, kind: kind, indexPath: indexPath)
    return view
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

  // keep reference to the factory that contains the data & closure functions
  private let factory: Any

  // Objective-C does not allow for class level generics, so store as native closures.
  var numberOfSections: NumberOfSectionsType?
  var numberOfItems: NumberOfItemsType?
  var headerTitle: TitleType?
  var footerTitle: TitleType?
  var cellForTable: TableType?
  var cellForCollection: CollectionType?
  var titleForCollection: CollectionTitleType?

  init<T: DataSourceFactoryType>(factory: T) {
    self.factory = factory
  }
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

 // 2. In your viewcontroller, add reference variable to the datasource
 
 let dataSource: UITableViewDataSource!

 
 // 3. Hook up your data so that you have a single value or array of Items that use same type as configure function above

 let items = [MyData(title: "first", value: 5), MyData(title: "second", value: 1)]


 // 4. In your viewcontroller's viewDidLoad method or similar, create your SectionData by using one or an array of Item values, see above.

 let sectionData = SectionData(items: items, headerTitle: "hello", footerTitle: nil)


 // 5. create factory, provide your cell type to it. Also, in Interface Builder, set your cell identifier as your cell class name e.g. "MyCell" in this example

 let factory = TableDataSourceFactory(cell: MyCell.self, sectionData)


 // 6. provide the datasource to your table view (or collectionview)

 dataSource = factory.tableViewDataSource  // remember to keep reference to the dataSource in your viewcontroller
 tableView.dataSource = self.dataSource
 
 */
