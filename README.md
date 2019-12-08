
# ProtoKit
 [![license MIT](https://img.shields.io/badge/license-MIT-000000.svg)][mitLink] [![Platform](https://img.shields.io/badge/platform-iOS-lightgray.svg)][docsLink]

*ProtoKit is a collection of protocols and extensions that make prototyping faster and easier with Swift programming language*

## Package

ProtoKit is structured as a Package (Swift Package Manager, SPM), each swift file contains a specific feature / functionality. 

Current features are:
  * SwiftUI Views
    * Arrow
    * Line
    * CircleShape (can be animated)
    * ProgressText (can be animated)
  * SwiftUI Extensions
    * uiHostingController
    * uiView
    * anyView
    * resizableHeightFont
  * UIKit Extensions
    * Bundle
    * CGRect
    * UIApplication
    * UICollectionView
    * UIColor
    * UIImage
    * UIImageView
    * UILabel
    * UIStoryboard
    * UITableView
  * Closurable (UIControl, UIButton, UIBarButtonItem, UIPageControl, UIGestureRecognizer)
  * Configurable
  * CoreDataStack
  * SourcedError (Custom ErrorType)
  * KVO
  * NotificationService / TypedNotification (way to pass data via observing/notifying)
  * SegueHandlerType
  * SelfPresentable (casting as Self)
  * Unified Collection (factory and related methods for creating UITableViewDataSources and UICollectionViewDataSources)

## Requirements

ProtoKit version 6.0 and later requires:
* iOS 13+ or tvOS 13+ or MacOS 10.15+
* Xcode 11.2 (Swift 5.1)
* watchOS is not supported


### Protocol naming conventions

Protocol types and naming conventions used in this framework:
  1. Can do => -able        => Hashable, RawRepresentable, Equatable
  2. Is a   => -Type        => CollectionType, SequenceType, ErrorType
  3. Can be => -Convertible => FloatLiteralConvertible, CustomStringConvertible


## Credits

Created and maintained by [**@moximillian**](https://twitter.com/moximillian).

Unified Collection inspired by 
* **[@jesse_squires](https://twitter.com/jesse_squires)**


## License

`ProtoKit` is released under an [MIT License][mitLink]. See `LICENSE` for details.

>**Copyright &copy; 2019-present Mox Soini.**

*Please provide attribution, it is greatly appreciated.*


[docsLink]:http://github.com/moximillian/ProtoKit
[mitLink]:http://opensource.org/licenses/MIT
