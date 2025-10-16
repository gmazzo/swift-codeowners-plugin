// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "swift-codeowners-plugin",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .plugin(name: "CodeOwnersPlugin", targets: ["CodeOwnersPlugin"]),
        .executable(name: "CodeOwnersTool", targets: ["CodeOwnersTool"])
    ],
    targets: [
        .plugin(
            name: "CodeOwnersPlugin",
            capability: .buildTool(),
            dependencies: ["CodeOwnersTool"]
        ),
        .executableTarget(
            name: "CodeOwnersTool",
            dependencies: []
        ),
        .target(
            name: "Demo",
            plugins: ["CodeOwnersPlugin"]
        ),
        .testTarget(
            name: "DemoTests",
            dependencies: ["Demo"]
        )
    ],
    swiftLanguageModes: [.v6, .v5]
)
