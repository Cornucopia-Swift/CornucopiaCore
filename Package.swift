// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "CornucopiaCore",
    platforms: [
        .iOS(.v18),
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
        .package(url: "https://github.com/mickeyl/FoundationBandAid", branch: "master"),
        .package(url: "https://github.com/apple/swift-crypto", .upToNextMajor(from: "3.15.0")),
        // NOTE: When upgrading to Swift 6, move to zmian's fork @ https://github.com/zmian/AnyCodable
        .package(url: "https://github.com/mickeyl/AnyCodable", .upToNextMajor(from: "0.6.6")),
        
    ],
    targets: [
        .target(
            name: "CornucopiaCore",
            dependencies: [
                // Android only needs FoundationBandAid's RunLoop.CC_cfRunLoop shim, implemented locally
                // instead (see RunLoop+CFRunLoopSource.swift) to avoid pulling in FoundationBandAid's
                // other extensions (e.g. its URLSession polyfills), which collide with declarations
                // FoundationNetworking already provides natively on Android.
                .product(name: "FoundationBandAid", package: "FoundationBandAid", condition: .when(platforms: [.linux])),
                // Apple platforms get MD5 from the system CryptoKit; swift-crypto is only
                // needed where CryptoKit is unavailable (keeps it out of the Apple build).
                .product(name: "Crypto", package: "swift-crypto", condition: .when(platforms: [.linux, .android, .windows, .wasi])),
                "AnyCodable",
                .target(name: "CAndroidPosixShims", condition: .when(platforms: [.android])),
                ]
            ),
        .systemLibrary(name: "CAndroidPosixShims"),
        .testTarget(
            name: "CornucopiaCoreTests",
            dependencies: ["CornucopiaCore"]
            ),
    ],
    swiftLanguageModes: [.v5]
)
