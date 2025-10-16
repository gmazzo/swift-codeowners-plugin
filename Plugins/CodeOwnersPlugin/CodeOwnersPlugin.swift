import PackagePlugin
import Foundation

@main
struct CodeOwnersPlugin: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let swiftTarget = target as? SwiftSourceModuleTarget else {
            fatalError("Target \(target.name) is not a Swift source module.")
        }
        let tool = try context.tool(named: "CodeOwnersTool")
        let inputFiles = swiftTarget.sourceFiles(withSuffix: ".swift").map { $0.path.string }
        let outputDir = context.pluginWorkDirectory

        return [
            .buildCommand(
                displayName: "Inject Code Owner into Swift files",
                executable: tool.path,
                arguments: inputFiles + ["--output", outputDir.string],
                inputFiles: swiftTarget.sourceFiles(withSuffix: ".swift").map { $0.path },
                outputFiles: inputFiles.map { outputDir.appending(subpath: URL(fileURLWithPath: $0).lastPathComponent) }
            )
        ]
    }

}
