// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "relux-network-monitor",
    defaultLocalization: "ru",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "ReluxNetworkMonitor",
            targets: ["ReluxNetworkMonitor"]
        ),
    ],
    dependencies: [
        // TODO: Switch back to remote after local Relux package changes settle.
        // .package(url: "https://github.com/relux-works/swift-relux.git", .upToNextMajor(from: "9.0.0")),
        .package(path: "../swift-relux"),
    ],
    targets: [
        .target(
            name: "ReluxNetworkMonitor",
            dependencies: [
                .product(name: "Relux", package: "swift-relux"),
            ],
            path: "Sources",
            swiftSettings: strictSwiftSettings
        ),
        .testTarget(
            name: "ReluxNetworkMonitorTests",
            dependencies: [
                "ReluxNetworkMonitor",
            ],
            path: "Tests",
            swiftSettings: strictSwiftSettings
        ),
    ]
)

let strictSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableUpcomingFeature("GlobalActorIsolatedTypesUsability"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("InferSendableFromCaptures"),
    .enableUpcomingFeature("GlobalConcurrency"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("NonfrozenEnumExhaustivity"),
    .enableUpcomingFeature("RegionBasedIsolation"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
]
