// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CornucopiaCore",
    platforms: [
        .iOS(.v14),
        .macOS(.v12),
        .tvOS(.v14),
        .watchOS(.v8),
        //.linux
    ],
    products: [
        .library(
            name: "CornucopiaCore",
            targets: ["CornucopiaCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/tsolomko/SWCompression", .upToNextMajor(from: "4.8.5")),
        .package(url: "https://github.com/mickeyl/AnyCodable", .upToNextMajor(from: "0.6.6")),
    ],
    targets: [
        .target(
            name: "CornucopiaCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "SWCompression", package: "SWCompression"),
                "AnyCodable",
                ]
            ),
        .testTarget(
            name: "CornucopiaCoreTests",
            dependencies: ["CornucopiaCore"]
            ),
    ]
)
