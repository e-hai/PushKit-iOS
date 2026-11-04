// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PushKit",
    defaultLocalization: "zh-Hans",
    platforms: [
        .iOS(.v15),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "PushKit",
            targets: ["PushKit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "PushKit",
            dependencies: [],
            path: "Sources/PushKit"
        ),
        .testTarget(
            name: "PushKitTests",
            dependencies: ["PushKit"],
            path: "Tests/PushKitTests"
        )
    ]
)
