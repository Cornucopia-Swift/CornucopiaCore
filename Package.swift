// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CornucopiaCore",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
        //.linux
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CornucopiaCore",
            targets: ["CornucopiaCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "1.1.0"))

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CornucopiaCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                ]
            ),
        .testTarget(
            name: "CornucopiaCoreTests",
            dependencies: ["CornucopiaCore"]),
    ]
)
