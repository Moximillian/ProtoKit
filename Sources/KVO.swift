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
 * Inspired by https://www.objc.io/blog/2018/04/24/bindings-with-kvo-and-keypaths/
 */

import Foundation

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
  public func bind<Value, Target: NSObject>(_ sourceKeyPath: KeyPath<Self, Value>,
                                            to target: Target,
                                            at targetKeyPath: ReferenceWritableKeyPath<Target, Value>) {
    
    let observation = observe(sourceKeyPath, options: [.initial, .new]) { [weak target] _, change in
      // The guard is because of https://bugs.swift.org/browse/SR-6066
      guard let newValue = change.newValue else { return }
      target?[keyPath: targetKeyPath] = newValue
    }
    let disposable = Disposable { observation.invalidate() }
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
