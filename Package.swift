// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftyNats",
    products: [
        .library(name: "SwiftyNats", targets: ["SwiftyNats"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "1.3.1"),
        //.package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
    ],
    targets: [
        .target(name: "SwiftyNats", dependencies: [
            "NIO",
            //.product(name: "Logging", package: "swift-log"),
        ]),
        .testTarget(name: "SwiftyNatsTests", dependencies: ["SwiftyNats"])
    ]
)
