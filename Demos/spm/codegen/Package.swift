// swift-tools-version:6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "SPM Codegen Demo",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    dependencies: [
        .package(name: "swift-codeowners-plugin", path: "../../..")
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
