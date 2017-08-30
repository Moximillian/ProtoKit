// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "ProtoKit",
  products: [
    .library(name: "ProtoKit", targets: ["ProtoKit"])
  ],
  dependencies: [],
  targets: [
    .target(name: "ProtoKit", dependencies: [], path: ".", sources: ["Sources"])
  ]
)
