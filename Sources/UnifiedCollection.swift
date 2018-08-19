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

#if canImport(UIKit)
  import UIKit
#elseif canImport(AppKit)
  import AppKit
#else
  #error("Unsupported platform.")
#endif

#if canImport(UIKit)

// MARK: - Unified Cell Type (protocol)

/// protocol for unified UITableViewCell and UICollectionViewCell
public protocol UnifiedCellType {
  associatedtype Collection: UnifiedCollectionType
}

extension UITableViewCell: UnifiedCellType {
  public typealias Collection = UITableView
}

extension UICollectionViewCell: UnifiedCellType {
  public typealias Collection = UICollectionView
}

// MARK: - Unified Collection Type (protocol)

/// protocol for unified UITableView and UICollectionView
public protocol UnifiedCollectionType {
  /// unified generic way to queue a table/collection cell of specific type
  func dequeueReusableCell<T: UnifiedCellType>(for indexPath: IndexPath) -> T
}

extension UITableView: UnifiedCollectionType {
  /// unified generic way to queue a UITableViewCell of specific type
  public func dequeueReusableCell<T: UnifiedCellType>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue tableview cell with identifier: \(T.self)")
    }
    return cell
  }
}

extension UICollectionView: UnifiedCollectionType {
  /// unified generic way to queue a UICollectionViewCell of specific type
  public func dequeueReusableCell<T: UnifiedCellType>(for indexPath: IndexPath) -> T {
    guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as? T else {
      fatalError("Could not dequeue collectionview cell with identifier: \(T.self)")
    }
    return cell
  }
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

// MARK: - Unified Cell Configurable (protocol)

// default (non-used) TitleView for UITableView
private class DefaultTitleView<Item>: UICollectionReusableView & UnifiedTitleConfigurable {
  public func configure(item: Item, collection: UICollectionView, kind: String, indexPath: IndexPath) {}
}

/// protocol for configuring UnifiedCellType. This should be conformed with the implemented cell class
public protocol UnifiedCellConfigurable: UnifiedCellType {
  associatedtype Item
  func configure(item: Item, collection: Collection, indexPath: IndexPath)
}

extension UnifiedCellConfigurable where Self: UITableViewCell {
  /// provide datasource for this type of cell
  public static func dataSource(sections: [SectionData<Item>]) -> UITableViewDataSource {
    return TableDataSource(factory: UnifiedDataSourceFactory<Self, DefaultTitleView<Item>>(sections: sections))
  }

  /// provide datasource for this type of cell, fancy pants version
  public static func dataSource(_ variadicSections: SectionData<Item>...) -> UITableViewDataSource {
    return dataSource(sections: variadicSections)
  }
}

extension UnifiedCellConfigurable where Self: UICollectionViewCell {
  /// provide datasource for this type of cell
  public static func dataSource<Title>(titleType: Title.Type,
                                       sections: [SectionData<Item>]) -> UICollectionViewDataSource
    where Title: UICollectionReusableView & UnifiedTitleConfigurable,
          Item == Title.Item {
    return CollectionDataSource(factory: UnifiedDataSourceFactory<Self, Title>(sections: sections))
  }

  /// provide datasource for this type of cell, fancy pants version
  public static func dataSource<Title>(titleType: Title.Type,
                                       _ variadicSections: SectionData<Item>...) -> UICollectionViewDataSource
    where Title: UICollectionReusableView & UnifiedTitleConfigurable,
          Item == Title.Item {
    return dataSource(titleType: titleType, sections: variadicSections)
  }
}

// MARK: - Unified Title Configurable (protocol)

/// protocol for unified UICollectionReusableView. This should be conformed with the implemented cell class
public protocol UnifiedTitleConfigurable {
  associatedtype Item
  func configure(item: Item, collection: UICollectionView, kind: String, indexPath: IndexPath)
}

// MARK: - Unified DataSource Factory (struct)

/// Factory for creating datasources
private struct UnifiedDataSourceFactory<Cell: UnifiedCellConfigurable,
                                        Title: UICollectionReusableView & UnifiedTitleConfigurable>
                                        where Cell.Item == Title.Item {

  private var sections: [SectionData<Cell.Item>]

  init(sections: [SectionData<Cell.Item>]) {
    self.sections = sections
  }

  // Common helpers
  private func item(at indexPath: IndexPath) -> Cell.Item {
    return sections[indexPath.section].items[indexPath.row]
  }

  private func cellFor(_ collection: Cell.Collection, at indexPath: IndexPath) -> Cell {
    let cell: Cell = collection.dequeueReusableCell(for: indexPath)
    cell.configure(item: item(at: indexPath), collection: collection, indexPath: indexPath)
    return cell
  }
}

// MARK: - Datasource Providers (protocols)

// Objective-C does not allow for class level generics, so provide data via native functions defined in protocol.
/// Unified functions that provide for both UITableViewDataSource and UICollectionViewDataSource
private protocol UnifiedDataProvider {
  func numberOfSections() -> Int
  func numberOfItems(in section: Int) -> Int
  func headerTitle(in section: Int) -> String?
  func footerTitle(in section: Int) -> String?
}

private protocol TableDataProvider: UnifiedDataProvider {
  func cell(for collection: UITableView, at indexPath: IndexPath) -> UITableViewCell
}

private protocol CollectionDataProvider: UnifiedDataProvider {
  func cell(for collection: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell
  func title(for collection: UICollectionView, of kind: String, at indexPath: IndexPath) -> UICollectionReusableView
}

// MARK: - UnifiedDataSourceFactory implementation of DataSourceProviders

extension UnifiedDataSourceFactory: UnifiedDataProvider {
  func numberOfSections() -> Int { return sections.count }
  func numberOfItems(in section: Int) -> Int { return sections[section].items.count }
  func headerTitle(in section: Int) -> String? { return sections[section].headerTitle }
  func footerTitle(in section: Int) -> String? { return sections[section].footerTitle }
}

extension UnifiedDataSourceFactory: TableDataProvider where Cell: UITableViewCell {
  func cell(for collection: UITableView, at indexPath: IndexPath) -> UITableViewCell {
    return cellFor(collection, at: indexPath)
  }
}

extension UnifiedDataSourceFactory: CollectionDataProvider where Cell: UICollectionViewCell {
  func cell(for collection: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
    return cellFor(collection, at: indexPath)
  }

  func title(for collection: UICollectionView, of kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let view: Title = collection.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
    view.configure(item: item(at: indexPath), collection: collection, kind: kind, indexPath: indexPath)
    return view
  }
}

// MARK: - Generic UnifiedDataSource (Objective-C class)

private class UnifiedDataSource<Factory>: NSObject {

  fileprivate let factory: Factory

  init(factory: Factory) {
    self.factory = factory
  }
}

/// UITableViewDataSource implementation for UnifiedDataSource (has to be non-generic)
fileprivate final class TableDataSource: UnifiedDataSource<TableDataProvider>, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return factory.numberOfSections()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return factory.numberOfItems(in: section)
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return factory.headerTitle(in: section)
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return factory.footerTitle(in: section)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return factory.cell(for: tableView, at: indexPath)
  }
}

/// UICollectionViewDataSource implementation for UnifiedDataSource (has to be non-generic)
fileprivate final class CollectionDataSource: UnifiedDataSource<CollectionDataProvider>,
                                              UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return factory.numberOfSections()
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return factory.numberOfItems(in: section)
  }

  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    return factory.title(for: collectionView, of: kind, at: indexPath)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    return factory.cell(for: collectionView, at: indexPath)
  }
}

#endif

/*
 //  -------- USAGE ----------

 // 1. create your cell (e.g. MyCell) and conform to UnifiedCellConfigurable by providing configure -method.
 // In the method, provide your actual class/struct type of your Items (here is MyData Struct as simple example).

 struct MyData {
   var title: String
   var value: Int
 }


 final class MyCell: UITableViewCell, UnifiedCellConfigurable {

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

 tableView.dataSource = self.dataSource  // remember to keep reference to the dataSource in your viewcontroller

 */
