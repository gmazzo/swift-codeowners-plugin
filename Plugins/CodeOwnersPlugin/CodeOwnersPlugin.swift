import PackagePlugin
import Foundation

@main
struct CodeOwnersPlugin: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let swiftTarget = target as? SwiftSourceModuleTarget else {
            Diagnostics.error("Target \(target.name) is not a Swift source module.")
            return []
        }

        let tool = try context.tool(named: "CodeOwnersTool")
        let inputFiles = swiftTarget.sourceFiles(withSuffix: ".swift").map(\.url)
        let outputDir = context.pluginWorkDirectoryURL

        return [
            .buildCommand(
                displayName: "CodeOwnership attribution for Swift files",
                executable: tool.url,
                arguments: inputFiles.map(\.absoluteString) + ["--output", outputDir.absoluteString],
                inputFiles: inputFiles,
                outputFiles: inputFiles.map { outputDir.appendingPathComponent("_" + $0.lastPathComponent) }
            )
        ]
    }

}
