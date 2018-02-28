// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftyNats",
    products: [
        .library(name: "SwiftyNats", targets: ["SwiftyNats"])
    ],
    dependencies: [ ],
    targets: [
        .target(name: "SwiftyNats", path: "Source"),
        .testTarget(name: "SwiftyNatsTest", dependencies: ["SwiftyNats"], path: "Tests")
    ]
)
