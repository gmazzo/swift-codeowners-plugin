// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "codeowners-plugin-demo",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    dependencies: [
        .package(url: "../", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "demo",
            plugins: [
                .plugin(name: "swift-codeowners-plugin", package: "swift-codeowners-plugin")
            ]
        ),
        .testTarget(
            name: "demo-tests",
            dependencies: ["demo"]
        )
    ]
)
