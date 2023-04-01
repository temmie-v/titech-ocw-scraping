// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TitechOCWScraping",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/TitechAppProject/titech-ocw-kit-swift", from: "0.8.0"),
        .package(url: "https://github.com/soto-project/soto.git", from: "6.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "TitechOCWScraping",
            dependencies: [
                .product(name: "TitechOCWKit", package: "titech-ocw-kit-swift"),
                .product(name: "SotoS3", package: "soto"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
    ]
)
