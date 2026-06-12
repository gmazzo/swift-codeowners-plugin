import ProjectDescription

let project = Project(
    name: "TuistDemo",
    packages: [
        .package(path: ".."),
    ],
    targets: [
        .target(
            name: "MacrosImpl",
            destinations: .macOS,
            product: .macro,
            bundleId: "com.glovo.MacrosImpl",
            deploymentTargets: .macOS("13.0"),
            buildableFolders: [.folder("Sources/MacrosImpl")],
            dependencies: [
                .package(product: "SwiftLint", type: .plugin),
                .package(product: "CodeOwnersMacro"),
                .package(product: "CodeOwnersMacroPlugin", type: .plugin)
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
            name: "Framework",
            destinations: .macOS,
            product: .framework,
            bundleId: "dev.tuist.Framework",
            buildableFolders: [.folder("Sources/Framework")],
            dependencies: [
                .target(name: "Macros"),
                .package(product: "SwiftLint", type: .plugin),
            ]
        ),
        .target(
            name: "FrameworkTest",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.FrameworkTest",
            buildableFolders: [.folder("Tests/FrameworkTest")],
            dependencies: [
                .target(name: "Framework"),
            ]
        ),
    ]
)
