import ProjectDescription

let project = Project(
    name: "Tuist Macro NoPlugin Demo",
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
            sources: [.generated("Derived/Sources/CodeOwnersInfo.swift")],
            buildableFolders: [.folder("Sources/MacrosImpl")],
            scripts: [
                .pre(
                    script: """
                            set -e
                            set -o pipefail
                            {
                              echo "let CODEOWNERS_ROOT = #\\\"$WORKSPACE_DIR\\\"#"
                              echo "let CODEOWNERS_CONTENT = #\\\"\\\"\\\""
                              cat "$SCRIPT_INPUT_FILE_0"
                              echo "\\\"\\\"\\\"#"
                            } > "$SCRIPT_OUTPUT_FILE_0"
                            echo "Generated file: $SCRIPT_OUTPUT_FILE_0"
                            """,
                    name: "Embed CODEOWNERS file content",
                    inputPaths: ["$(WORKSPACE_DIR)/CODEOWNERS"],
                    outputPaths: ["Derived/Sources/CodeOwnersInfo.swift"],
                )
            ],
            dependencies: [
                .external(name: "CodeOwnersMacroBase"),
            ]
        ),
    ]
)
