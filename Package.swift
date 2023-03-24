// swift-tools-version:5.8
import PackageDescription

let package = Package(
  name: "ProtoKit",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v16),
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
      from: "3.0.0"
    )
  ],
  targets: [
    .target(
      name: "ProtoKit",
      dependencies: ["Then"],
      path: ".",
      exclude: ["Tests", "README.md", "build.sh", "LICENSE"],
      sources: ["Sources"],
      swiftSettings: [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("ImplicitOpenExistentials")
      ]
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
