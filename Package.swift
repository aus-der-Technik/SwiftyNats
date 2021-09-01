// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "SwiftyNats",
    products: [
        .library(name: "SwiftyNats", targets: ["SwiftyNats"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.3.1"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
    ],
    targets: [
        .target(name: "SwiftyNats", dependencies: [
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "SwiftyNatsTests", dependencies: ["SwiftyNats"])
    ]
)
