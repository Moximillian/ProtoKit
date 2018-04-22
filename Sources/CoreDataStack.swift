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

import Foundation

import CoreData
import Then

// MARK: – Core Data Protocols and extensions

public protocol SortableManagedObject: NSFetchRequestResult {
  static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

extension SortableManagedObject where Self: NSManagedObject {

  @available(iOS 10.0, macOS 10.12, *)
  public static func sortedFetchRequest() -> NSFetchRequest<Self> {
    let request = Self.fetchRequest() as! NSFetchRequest<Self>
    request.sortDescriptors = defaultSortDescriptors
    return request
  }

  // TODO: can use also predicates (add as parameter with default value)
  // fetchRequest.predicate = Predicate(format: "SELF IN %@", objects as CVarArg)
}
@available(iOS 10.0, macOS 10.12, *)
extension NSPersistentContainer {
  public func getQueryGenerationViewContext() throws -> NSManagedObjectContext {
    let context = viewContext
    try context.setQueryGenerationFrom(.current)
    return context
  }
}

// MARK: - Core Data stack
// check also https://developer.apple.com/videos/play/wwdc2016/242/

public final class CoreDataStack {
  private let name: String

  public required init(name: String) {
    self.name = name
  }

  @available(iOS 10.0, macOS 10.12, *)
  public lazy var persistentContainer: NSPersistentContainer = NSPersistentContainer(name: name).then {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    $0.loadPersistentStores(completionHandler: { (storeDescription, error) in
      /*
       Typical reasons for an error here include:
       * The parent directory does not exist, cannot be created, or disallows writing.
       * The persistent store is not accessible, due to permissions or data protection when the device is locked.
       * The device is out of space.
       * The store could not be migrated to the current model version.
       Check the error message to determine what the actual problem was.
       */
      let userInfo = (error as NSError?)?.userInfo ?? [:]
      fatalError("Unresolved error in \(storeDescription) – \(String(describing: error)), \(userInfo)")
    })
  }

  // MARK: - Core Data Saving support
  @available(iOS 10.0, macOS 10.12, *)
  public func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        fatalError("Unresolved error \(error), \((error as NSError).userInfo)")
      }
    }
  }
}
