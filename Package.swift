// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "process-kit",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "ProcessKit",
            targets: ["ProcessKit"]),
    ],
    targets: [
        .target(
            name: "ProcessKit"),
        .testTarget(
            name: "ProcessKitTests",
            dependencies: ["ProcessKit"],
            resources: [.process("MyGrep.sh")]
        ),
    ]
)
