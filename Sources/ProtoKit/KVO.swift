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
 * Originally inspired by https://www.objc.io/blog/2018/04/24/bindings-with-kvo-and-keypaths/
 */

import Foundation
import Combine

class Disposable {
  typealias DisposeFunction = () -> Void
  let dispose: DisposeFunction

  init(_ dispose: @escaping DisposeFunction) {
    self.dispose = dispose
  }

  deinit {
    dispose()
  }
}

extension NSObjectProtocol where Self: NSObject {

  /// observe a variable (as keypath) from this instance, bind it to target instance's variable (keypath)
  /// *** NOTE: observed value MUST be declared `@objc dynamic` ***
  @available(iOS 13.0, OSX 10.15, tvOS 13.0, *)
  public func bind<Value, Target: NSObject>(_ sourceKeyPath: KeyPath<Self, Value>,
                                             to target: Target,
                                             at targetKeyPath: ReferenceWritableKeyPath<Target, Value>) {


    // NOTE: Target has to be NSObject only because of storing the associated object.
    // publisher/assign works fine with swift classes as Targets.
    let cancellable: AnyCancellable = publisher(for: sourceKeyPath).assign(to: targetKeyPath, on: target)
    let disposable = Disposable { cancellable.cancel() }
    target.store(associatedObject: disposable)
  }
}

/*
 //  -------- USAGE ----------

 // 1. create e.g. a model or viewmodel (must inherit from NSObject or its subclass) that you want to observe.
 // Observed variable must be "@obj dynamic".

 final class Model: NSObject {
   @objc dynamic var value: Int = 0
 }

 // 2. create a target class (must inherit from NSObject or its subclass), for example a viewcontroller or view.

 final class Target: NSObject {
   var targetValue: Int = 0
 }

 // 3. Make sure both are instantiated and can be referred to from the same place

 let model = Model()
 let target = Target()


 // 4. bind model variable to target

 model.bind(\.value, to: target, at: \.targetValue)


 // 5. From now on any change in model variable also changes targetValue

 model.value = 42
 print(target.targetValue) // 42

 */
