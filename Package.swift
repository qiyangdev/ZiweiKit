// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ZiweiKit",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
    .visionOS(.v1),
  ],
  products: [
    .library(name: "ZiweiKit", targets: ["ZiweiKit"])
  ],
  targets: [
    .target(name: "ZiweiKit"),
    .testTarget(
      name: "ZiweiKitTests",
      dependencies: ["ZiweiKit"],
      resources: [.process("Fixtures")]
    ),
  ]
)
