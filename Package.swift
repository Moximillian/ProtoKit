// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "ProtoKit",
  products: [
    .library(
      name: "ProtoKit",
      targets: ["ProtoKit"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/devxoul/Then",
      from: "2.4.0"
    )
  ],
  targets: [
    .target(
      name: "ProtoKit",
      dependencies: ["Then"],
      path: ".",
      sources: ["Sources"]
    ),
    .testTarget(
      name: "ProtoKitTests",
      dependencies: ["ProtoKit"],
      path: ".",
      sources: ["Tests"]
    )
  ]
)
