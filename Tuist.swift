import ProjectDescription

let tuist = Tuist(
    fullHandle: "gmazzo/swift-codeowners-plugin",
    project: .tuist(
        generationOptions: .options(
            enableCaching: true
        )
    )
)
