// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "swift-codeowners-plugin",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13)
    ],
    products: [
        .plugin(name: "swift-codeowners-plugin", targets: ["CodeOwnersPlugin"]),
        .executable(name: "swift-codeowners-tool", targets: ["CodeOwnersTool"])
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
        )
    ]
)
