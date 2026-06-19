// swift-tools-version:6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "swift-codeowners-plugin",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
    ],
    products: [
        .plugin(name: "CodeOwnersPlugin", targets: ["CodeOwnersPlugin"]),
        .executable(name: "CodeOwnersTool", targets: ["CodeOwnersTool"]),
        .library(name: "CodeOwnersAPI", targets: ["CodeOwnersAPI"]),
        .plugin(name: "CodeOwnersMacroPlugin", targets: ["CodeOwnersMacroPlugin"]),
        .executable(name: "CodeOwnersMacroTool", targets: ["CodeOwnersMacroTool"]),
        .library(name: "CodeOwnersMacroBase", targets: ["CodeOwnersMacroBase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.1"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "603.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.2"),
        .package(url: "https://github.com/mtj0928/swift-codeowners", from: "0.1.1"),
    ],
    targets: [
        .plugin(name: "CodeOwnersPlugin", capability: .buildTool(), dependencies: ["CodeOwnersTool"]),
        .executableTarget(name: "CodeOwnersTool", dependencies: [
            "CodeOwnersResolver",
            .product(name: "SwiftParser", package: "swift-syntax"),
        ]),
        .plugin(name: "CodeOwnersMacroPlugin", capability: .buildTool(), dependencies: ["CodeOwnersMacroTool"]),
        .executableTarget(name: "CodeOwnersMacroTool", dependencies: [
            "CodeOwnersResolver",
            .product(name: "SwiftSyntax", package: "swift-syntax"),
        ]),
        .target(name: "CodeOwnersMacroBase", dependencies: [
            "CodeOwnersResolver",
            .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        ]),
        .target(name: "CodeOwnersResolver", dependencies: [
            .product(name: "PathKit", package: "PathKit"),
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "CodeOwners", package: "swift-codeowners")
        ]),
        .target(name: "CodeOwnersAPI"),
        .testTarget(name: "CodeOwnersAPITests", dependencies: ["CodeOwnersAPI"]),
        .testTarget(name: "CodeOwnersToolTests", dependencies: ["CodeOwnersTool"]),
        .testTarget(name: "CodeOwnersResolverTests", dependencies: ["CodeOwnersResolver"]),
        .testTarget(name: "CodeOwnersMacroBaseTests", dependencies: [
            "CodeOwnersMacroBase",
            .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
        ]),
    ]
)
