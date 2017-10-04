// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "ProtoKit",
  products: [
    .library(name: "ProtoKit", targets: ["ProtoKit"])
  ],
  dependencies: [
    .package(url: "https://github.com/devxoul/Then", from: "2.2.0")
  ],
  targets: [
    .target(name: "ProtoKit", dependencies: ["Then"], path: ".", sources: ["Sources"])
  ],
  swiftLanguageVersions: [4]
)
