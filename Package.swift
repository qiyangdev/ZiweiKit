// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ZiweiCore",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "ZiweiCore", targets: ["ZiweiCore"])
  ],
  targets: [
    .target(name: "ZiweiCore"),
    .testTarget(
      name: "ZiweiCoreTests",
      dependencies: ["ZiweiCore"],
      resources: [.process("Fixtures")]
    ),
  ]
)
