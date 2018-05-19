//
//  Created by Mox Soini
//  https://www.linkedin.com/in/moxsoini
//
//  GitHub
//  https://github.com/moximillian/ProtoKit
//
//  License
//  Copyright © 2018 Mox Soini
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

/*
 * inspired by https://twitter.com/jaredsinclair/status/951536021459619840
*/

import Foundation

/// Register Notification Observers using closure, comes with automatic observer removal
public final class Observer {
  private var observers: [NSObjectProtocol] = []
  private let queue: OperationQueue

  public init(queue: OperationQueue = .main) {
    self.queue = queue
  }

  deinit {
    observers.forEach { NotificationCenter.default.removeObserver($0) }
  }

  public func add(_ name: Notification.Name, using block: @escaping (Notification) -> Void) {
    let observer = NotificationCenter.default.addObserver(forName: name, object: nil, queue: queue, using: block)
    observers.append(observer)
  }
}

/// generic struct that holds notifications containing a value of specific type
public struct TypedNotification<ObjectType> {
  private var title: NSString

  public init(title: NSString) {
    self.title = title
  }
  public var name: Notification.Name { return title as Notification.Name }
}

extension Observer {
  /// add listening notification that acts on predefined (typed) value
  public func add<T>(_ typedNotification: TypedNotification<T>, using block: @escaping (T) -> Void) {
    add(typedNotification.name) { notification in
      guard let value = notification.userInfo?[typedNotification.name] as? T else {
        fatalError("Observer: invalid TypedNotification value type")
      }
      block(value)
    }
  }

  /// post notification that uses predefined (typed) value
  public static func post<T>(_ typedNotification: TypedNotification<T>, value: T) {
    NotificationCenter.default.post(name: typedNotification.name, object: nil, userInfo: [typedNotification.name: value])
  }
}

/*
 //  -------- USAGE ----------

 // 1. define your notifications as TypedNotifications

 struct MyNotifications {
   static var note1 = TypedNotification<Int>(title: "myNotification1")
   static var note2 = TypedNotification<String>(title: "myNotification2")
 }

// 2a.For listening to notifications instantiate observer inside your viewcontroller
// 2b. ...and add the notification

  class myVC: UIViewController {
    let observer = Observer()

    override func viewDidLoad() {
      super.viewDidLoad()

      observer.add(MyNotifications.note1) { [weak self] value in
        // do stuff with value
      }
    }
  }

// 3. For posting notifications, just use Observer.post()

  Observer.post(MyNotifications.note1, value: 2)

*/
