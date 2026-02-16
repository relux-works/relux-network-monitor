// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "relux-network-monitor",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "ReluxNetworkMonitor",
            targets: ["ReluxNetworkMonitor"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/relux-works/swift-relux.git", .upToNextMajor(from: "8.1.0")),
    ],
    targets: [
        .target(
            name: "ReluxNetworkMonitor",
            dependencies: [
                .product(name: "Relux", package: "swift-relux"),
            ],
            path: "Sources"
        )
    ]
)

