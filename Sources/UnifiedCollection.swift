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

#if os(iOS) || os(tvOS)
  import UIKit
#elseif os(macOS)
  import AppKit
#endif

// MARK: - Unified Collection

#if os(iOS) || os(tvOS)

// MARK: - Unified Cell Type

/// protocol defining the capability to have Collection
public protocol HasCollection {
  associatedtype Collection
}

extension UITableViewCell: HasCollection {
  public typealias Collection = UITableView
}

extension UICollectionViewCell: HasCollection {
  public typealias Collection = UICollectionView
}

/// protocol for unified UITableViewCell and UICollectionViewCell. This should be conformed with the implemented cell class
public protocol UnifiedCellType: HasCollection {
  associatedtype Item
  func configure(item: Item, collection: Collection, indexPath: IndexPath)
}

/// protocol for unified UICollectionReusableView. This should be conformed with the implemented cell class
public protocol UnifiedTitleType {
  associatedtype Item
  func configure(item: Item, collection: UICollectionView, kind: String, indexPath: IndexPath)
}


// MARK: - Section data (source data container)

/// Factory valuetype for section protocol
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

// MARK: - Unified Datasource Factory

/// Protocol for data source factories
public protocol DataSourceFactoryType {
  associatedtype Cell: UnifiedCellType
  associatedtype Section where Section == SectionData<Cell.Item>

  var sections: [Section] { get }
  func dequeCell(for collection: Cell.Collection, indexPath: IndexPath) -> Cell
}

extension DataSourceFactoryType {

  // MARK: - DataSourceFactoryType implementations for common functions

  fileprivate func item(at indexPath: IndexPath) -> Cell.Item {
    return sections[indexPath.section].items[indexPath.row]
  }

  fileprivate func cell(for collection: Cell.Collection, indexPath: IndexPath) -> Cell {
    let cell: Cell = dequeCell(for: collection, indexPath: indexPath)
    cell.configure(item: item(at: indexPath), collection: collection, indexPath: indexPath)
    return cell
  }
}

/// Factory for creating UITableViewDataSource
public final class TableDataSourceFactory<Cell: UITableViewCell & UnifiedCellType>: DataSourceFactoryType {
  public typealias Section = SectionData<Cell.Item>

  private(set) public var sections: [Section]

  /// fancy pants convenience init for UITableView
  public convenience init(_ sections: Section...) {
    self.init(sections: sections)
  }

  /// Init for UITableView
  public required init(sections: [Section]) {
    self.sections = sections
  }

  /// TableViewDataSource from UnifiedDataSource
  public var tableViewDataSource: UITableViewDataSource {
    let source = UnifiedDataSource(factory: self)
    // store functions as closures in UnifiedDataSource. Cannot assign functions directly due to retain cycles
    source.numberOfSections = { [unowned self] in return self.sections.count }
    source.numberOfItems = { [unowned self] in return self.sections[$0].items.count }
    source.headerTitle = { [unowned self] in return self.sections[$0].headerTitle }
    source.footerTitle = { [unowned self] in return self.sections[$0].footerTitle }
    source.cellForTable = { [unowned self] in return self.cell(for: $0, indexPath: $1) }
    return source
  }

  public func dequeCell(for collection: Cell.Collection, indexPath: IndexPath) -> Cell {
    return collection.dequeueReusableCell(for: indexPath)  // UITableView extension
  }
}


/// Factory for creating UICollectionViewDataSource
public final class CollectionDataSourceFactory<Cell: UICollectionViewCell & UnifiedCellType, Title: UICollectionReusableView & UnifiedTitleType>: DataSourceFactoryType
  where Cell.Item == Title.Item  {
  public typealias Section = SectionData<Cell.Item>

  private(set) public var sections: [Section]

  /// fancy pants convenience init for UICollectionView
  public convenience init(_ sections: Section...) {
    self.init(sections: sections)
  }

  /// Init for UICollectionView
  public required init(sections: [Section]) {
    self.sections = sections
  }

  /// CollectionViewSource from UnifiedDataSource
  public var collectionViewDataSource: UICollectionViewDataSource {
    let source = UnifiedDataSource(factory: self)
    // store functions as closures in UnifiedDataSource. Cannot assign functions directly due to retain cycles
    source.numberOfSections = { [unowned self] in return self.sections.count }
    source.numberOfItems = { [unowned self] in return self.sections[$0].items.count }
    source.cellForCollection = { [unowned self] in return self.cell(for: $0, indexPath: $1) }
    source.titleForCollection = { [unowned self] in return self.titleForCollection(collection: $0, kind: $1, indexPath: $2) }
    return source
  }

  // MARK: DataSourceFactoryType implementations for UICollectionView

  public func dequeCell(for collection: Cell.Collection, indexPath: IndexPath) -> Cell {
    return collection.dequeueReusableCell(for: indexPath)  // UICollectionView extension
  }

  private func titleForCollection(collection: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView {
    let view: Title = collection.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
    view.configure(item: item(at: indexPath), collection: collection, kind: kind, indexPath: indexPath)
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
    return numberOfSections!()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfItems!(section)
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return headerTitle!(section)
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return footerTitle!(section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return cellForTable!(tableView, indexPath)
  }
}

/// UICollectionViewDataSource implementation of UnifiedDataSourceType
extension UnifiedDataSource: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return numberOfSections!()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return numberOfItems!(section)
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    return titleForCollection!(collectionView, kind, indexPath)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return cellForCollection!(collectionView, indexPath)
  }
}

#endif


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
 detailTextLabel?.text = "\(item.value)"
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

 let factory = TableDataSourceFactory<MyCell>(sectionData)


 // 6. provide the datasource to your table view (or collectionview)

 dataSource = factory.tableViewDataSource  // remember to keep reference to the dataSource in your viewcontroller
 tableView.dataSource = self.dataSource
 
 */
