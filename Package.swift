// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "ProtoKit",
  platforms: [
    .macOS(.v12),
    .iOS(.v15),
    .tvOS(.v15),
  ],
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
      exclude: ["Tests", "README.md", "build.sh", "LICENSE"],
      sources: ["Sources"]
    ),
    .testTarget(
      name: "ProtoKitTests",
      dependencies: ["ProtoKit"],
      path: ".",
      exclude: ["Sources", "README.md", "build.sh", "LICENSE"],
      sources: ["Tests"]
    )
  ]
)
