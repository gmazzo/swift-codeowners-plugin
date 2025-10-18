// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "swift-codeowners-plugin",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .plugin(name: "CodeOwnersPlugin", targets: ["CodeOwnersPlugin"]),
        .executable(name: "CodeOwnersTool", targets: ["CodeOwnersTool"]),
        .library(name: "CodeOwnersCore", targets: ["CodeOwnersCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/mtj0928/swift-codeowners", from: "0.1.0"),
    ],
    targets: [
        .plugin(name: "CodeOwnersPlugin", capability: .buildTool(), dependencies: ["CodeOwnersTool"]),
        .executableTarget(name: "CodeOwnersTool", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            .product(name: "SwiftSyntax", package: "swift-syntax"),
            .product(name: "SwiftParser", package: "swift-syntax"),
            .product(name: "CodeOwners", package: "swift-codeowners"),
        ]),
        .target(name: "CodeOwnersCore"),
    ]
)
