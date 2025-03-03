// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "CornucopiaCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .macCatalyst(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        //.linux
    ],
    products: [
        .library(
            name: "CornucopiaCore",
            targets: ["CornucopiaCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto", .upToNextMajor(from: "3.11.0")),
        .package(url: "https://github.com/tsolomko/SWCompression", .upToNextMajor(from: "4.8.6")),
        // NOTE: When upgrading to Swift 6, move to zmian's fork @ https://github.com/zmian/AnyCodable
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
