import PackagePlugin
import Foundation

@main
struct CodeOwnersPlugin: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let swiftTarget = target as? SwiftSourceModuleTarget else {
            Diagnostics.error("Target \(target.name) is not a Swift source module.")
            return []
        }
        
        guard let inputs = Inputs.lookup(atRoot: context.package.directoryURL) else {
            Diagnostics.error("Failed to infer CODEOWNERS file root for target \(target.name)")
            return []
        }

        let inputFiles = swiftTarget.sourceFiles(withSuffix: ".swift").map(\.url)
        if (inputFiles.isEmpty) {
            Diagnostics.warning("Target \(target.name) does not contain any Swift source files.")
            return []
        }

        let tool = try context.tool(named: "CodeOwnersTool")
        let outputFile = context.pluginWorkDirectoryURL.appendingPathComponent("CodeOwners.swift")

        return [.buildCommand(
            displayName: "CodeOwner attribution",
            executable: tool.url,
            arguments: inputFiles.map(\.path) + ["--output-file", outputFile.path],
            inputFiles: inputs.files + inputFiles,
            outputFiles: [outputFile]
        )]
    }

}
