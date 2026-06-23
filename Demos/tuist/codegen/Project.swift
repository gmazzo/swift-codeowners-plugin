import ProjectDescription

let project = Project(
    name: "Tuist Codegen Demo",
    packages: [
        .package(path: "../../.."),
    ],
    targets: [
        .target(
            name: "Demo",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.Demo",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: [.folder("Sources/Demo")],
            dependencies: [
                .package(product: "CodeOwnersAPI"),
                .package(product: "CodeOwnersPlugin", type: .plugin),
            ]
        ),
        .target(
            name: "DemoTest",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.FrameworkTest",
            deploymentTargets: .iOS("16.0"),
            buildableFolders: [.folder("Tests/DemoTests")],
            dependencies: [
                .target(name: "Demo"),
            ]
        ),
    ]
)
