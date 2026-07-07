// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "liquid_glass_kit",
  platforms: [.iOS("16.0")],
  products: [
    .library(name: "liquid-glass-kit", targets: ["liquid_glass_kit"]),
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ],
  targets: [
    .target(
      name: "liquid_glass_kit",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ]
    ),
  ]
)
