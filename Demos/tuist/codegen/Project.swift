import ProjectDescription

let project = Project(
    name: "Tuist Codegen Demo",
    packages: [
        .package(path: "../../.."),
    ],
    targets: [
        .target(
            name: "Demo",
            destinations: .macOS,
            product: .framework,
            bundleId: "dev.tuist.Demo",
            buildableFolders: [.folder("Sources/Demo")],
            dependencies: [
                .package(product: "CodeOwnersAPI"),
                .package(product: "CodeOwnersPlugin", type: .plugin),
            ]
        ),
        .target(
            name: "DemoTest",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.FrameworkTest",
            buildableFolders: [.folder("Tests/DemoTests")],
            dependencies: [
                .target(name: "Demo"),
            ]
        ),
    ]
)
