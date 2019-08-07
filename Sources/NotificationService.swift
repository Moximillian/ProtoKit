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
 * Updated to use Combine (Framework)
 * originally inspired by https://twitter.com/jaredsinclair/status/951536021459619840
*/

import Foundation
import Combine

/// Register Notification Observers using closure, comes with automatic observer removal
@available(iOS 13.0, macOS 10.15, *)
public final class NotificationService {
  private var cancellables: [AnyCancellable] = []

  public init() {}

  deinit {
    cancellables.forEach { $0.cancel() }
  }

  private func listen(to name: Notification.Name, using block: @escaping (Notification) -> Void) {
    let cancellable = NotificationCenter.default.publisher(for: name).sink(receiveValue: block)
    cancellables.append(cancellable)
  }
}

/// generic struct that holds notifications containing a value of specific type
public struct TypedNotification<ObjectType> {
  public private(set) var name: Notification.Name

  public init(title: String) {
    name = NSString(string: title) as Notification.Name
  }
}

@available(iOS 13.0, macOS 10.15, *)
extension NotificationService {
  /// add listening notification that acts on predefined (typed) value
  public func listen<T>(to notification: TypedNotification<T>, using block: @escaping (T) -> Void) {
    listen(to: notification.name) { notification in
      guard let value = notification.object as? T else {
        fatalError("Observer: invalid TypedNotification value type")
      }
      block(value)
    }
  }

  /// post notification that uses predefined (typed) value
  public static func post<T>(_ notification: TypedNotification<T>, value: T) {
    NotificationCenter.default.post(name: notification.name, object: value)
  }
}

/*
 //  -------- USAGE ----------

 // 1. define your notifications as TypedNotifications

 extension TypedNotification {
   static var note1: TypedNotification<Int> { return .init(title: "myNotification1") }
   static var note2: TypedNotification<String> { return .init(title: "myNotification2") }
 }

// 2a.For listening to notifications instantiate NotificationService inside your viewcontroller
// 2b. ...and listen to the notification

  class myVC: UIViewController {
    let notificationService = NotificationService()

    override func viewDidLoad() {
      super.viewDidLoad()

      notificationService.listen(to: MyNotifications.note1) { [weak self] value in
        // do stuff with value
      }
    }
  }

// 3. For posting notifications, just use NotificationService.post()

  NotificationService.post(MyNotifications.note1, value: 2)

*/
