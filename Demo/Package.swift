// swift-tools-version:6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Demo Project",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    dependencies: [
        .package(name: "swift-codeowners-plugin", path: "../"),
    ],
    targets: [
        .target(
            name: "Demo",
            dependencies: [
                "MacrosAPI",
                .product(name: "CodeOwnersAPI", package: "swift-codeowners-plugin")
            ],
            plugins: [
                .plugin(name: "CodeOwnersPlugin", package: "swift-codeowners-plugin")
            ]
        ),
        .target(name: "MacrosAPI", dependencies: ["Macros"]),
        .macro(
            name: "Macros",
            dependencies: [
                .product(name: "CodeOwnersMacro", package: "swift-codeowners-plugin"),
            ],
            plugins: [
                .plugin(name: "CodeOwnersMacroPlugin", package: "swift-codeowners-plugin")
            ]
        ),
        .testTarget(name: "DemoTests", dependencies: ["Demo"]),
    ]
)
