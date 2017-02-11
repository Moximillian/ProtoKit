
# ProtoKit
 [![license MIT](https://img.shields.io/badge/license-MIT-000000.svg)][mitLink] [![Platform](https://img.shields.io/badge/platform-iOS-lightgray.svg)][docsLink]

*ProtoKit is a collection of protocols and extensions that make prototyping faster and easier with Swift programming language*

## Package

ProtoKit is structured as a Package (Swift Package Manager), each swift file contains a specific feature / functionality. Because Swift Package Manager currently lacks support for iOS, a build.sh -script is provided to facilitate use of this framework.

Current features are:
  * Extensions
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
  * SourcedError (Custom ErrorType)
  * Injectable
  * SegueHandlerType
  * Unified Collection (factory and related methods for creating UITableViewDataSources and UICollectionViewDataSources)

## Requirements

* iOS 10+
* Swift 3.0
* Xcode 8


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

>**Copyright &copy; 2015-present Mox Soini.**

*Please provide attribution, it is greatly appreciated.*


[docsLink]:http://github.com/moximillian/ProtoKit
[mitLink]:http://opensource.org/licenses/MIT
