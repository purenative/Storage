// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Storage",
            targets: ["Storage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/realm-swift",
                 from: "10.21.1"),
        .package(url: "https://github.com/apple/swift-collections.git",
                 from: "1.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Storage",
            dependencies: []),
        .testTarget(
            name: "StorageTests",
            dependencies: ["Storage"]),
    ]
)
