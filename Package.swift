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
        .package(url: "https://github.com/SwiftfulThinking/SwiftfulLoadingIndicators.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "SwiftUIUtilities",
            dependencies: [
                "SwiftfulRouting",
                "SwiftfulLoadingIndicators"
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
