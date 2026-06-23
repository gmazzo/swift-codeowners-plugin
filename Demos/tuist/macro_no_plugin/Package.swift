// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Tuist Macro NoPlugin Demo",
    dependencies: [
        // FIXME This is a workaround on issue of Tuist trying to load unsupported targets
        // .package(path: "../../..")
        .package(url: "https://github.com/gmazzo/swift-codeowners-plugin", branch: "main"),
    ],
)
