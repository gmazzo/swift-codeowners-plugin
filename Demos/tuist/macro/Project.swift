import ProjectDescription

let project = Project(
    name: "Tuist Macro Demo",
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
                .target(name: "Macros"),
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
        .target(
            name: "Macros",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.glovo.Macros",
            buildableFolders: [.folder("Sources/Macros")],
            dependencies: [
                .target(name: "MacrosImpl")
            ]
        ),
        .target(
            name: "MacrosImpl",
            destinations: .macOS,
            product: .macro,
            bundleId: "com.glovo.MacrosImpl",
            deploymentTargets: .macOS("13.0"),
            buildableFolders: [.folder("Sources/MacrosImpl")],
            dependencies: [
                .package(product: "CodeOwnersMacroBase"),
                .package(product: "CodeOwnersMacroPlugin", type: .plugin)
            ]
        ),
    ]
)
