// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "Demo Project",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    dependencies: [
        .package(path: ".."),
    ],
    targets: [
        .target(
            name: "Demo",
            dependencies: [
                .product(name: "CodeOwnersAPI", package: "swift-codeowners-plugin")
            ],
            plugins: [
                .plugin(name: "CodeOwnersPlugin", package: "swift-codeowners-plugin")
            ]
        ),
        .testTarget(name: "DemoTests", dependencies: ["Demo"]),
    ]
)
