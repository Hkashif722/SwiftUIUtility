// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUIUtilities",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftUIUtilities",
            targets: ["SwiftUIUtilities"]
        ),
    ],
    dependencies: [
        // SwiftfulRouting for navigation
        .package(url: "https://github.com/SwiftfulThinking/SwiftfulRouting.git", from: "5.0.0"),
        // SwiftfulLoadingIndicators for loading animations
        .package(url: "https://github.com/SwiftfulThinking/SwiftfulLoadingIndicators.git", from: "0.0.1"),
        .package(url: "https://github.com/kean/Nuke.git", .upToNextMajor(from: "12.8.0"))
    ],
    targets: [
        .target(
            name: "SwiftUIUtilities",
            dependencies: [
                // Update these to use the .product syntax
                .product(name: "SwiftfulRouting", package: "SwiftfulRouting"),
                .product(name: "SwiftfulLoadingIndicators", package: "SwiftfulLoadingIndicators"),
                .product(name: "Nuke", package: "Nuke")
            ],
            path: "Sources/SwiftUIUtilities",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SwiftUIUtilitiesTests",
            dependencies: ["SwiftUIUtilities"],
            path: "Tests/SwiftUIUtilitiesTests"
        ),
    ]
)
