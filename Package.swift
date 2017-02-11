import PackageDescription

let package = Package(
  name: "ProtoKit",
  dependencies: [],
  exclude: []
)

// Runtime Library
products.append(
  Product(
    name: "ProtoKit",
    type: .Library(.Dynamic),
    modules: ["ProtoKit"]
  )
)
