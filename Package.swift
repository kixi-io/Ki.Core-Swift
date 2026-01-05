// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KiCore",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "KiCore",
            targets: ["KiCore"]
        ),
    ],
    targets: [
        .target(
            name: "KiCore",
            path: "Sources/KiCore"
        ),
        .testTarget(
            name: "KiCoreTests",
            dependencies: ["KiCore"],
            path: "Tests/KiCoreTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
