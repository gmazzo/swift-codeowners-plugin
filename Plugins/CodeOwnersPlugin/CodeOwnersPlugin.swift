import PackagePlugin
import Foundation

@main
struct CodeOwnersPlugin: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let swiftTarget = target as? SwiftSourceModuleTarget else {
            Diagnostics.error("Target \(target.name) is not a Swift source module.")
            return []
        }
        
        return try buildCommands(
            targetName: target.name,
            root: context.package.directoryURL,
            workingDir: context.pluginWorkDirectoryURL,
            inputFiles: swiftTarget.sourceFiles(withSuffix: ".swift").map(\.url),
            tool: try context.tool(named: "CodeOwnersTool")
        )
    }
    
    private func buildCommands(targetName: String, root: URL, workingDir: URL, inputFiles: [URL], tool: PackagePlugin.PluginContext.Tool) throws -> [Command] {
        guard let inputs = Inputs.lookup(atRoot: root) else {
            Diagnostics.error("Failed to infer CODEOWNERS file root for target \(targetName)")
            return []
        }

        if (inputFiles.isEmpty) {
            Diagnostics.warning("Target \(targetName) does not contain any Swift source files.")
            return []
        }
        
        let outputFile = workingDir.appendingPathComponent("CodeOwners.swift")

        return [.buildCommand(
            displayName: "CodeOwner attribution",
            executable: tool.url,
            arguments: inputFiles.map(\.path) + ["--output-file", outputFile.path],
            inputFiles: inputs.files + inputFiles,
            outputFiles: [outputFile]
        )]
    }

}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension CodeOwnersPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        return try buildCommands(
            targetName: target.displayName,
            root: context.xcodeProject.directoryURL,
            workingDir: context.pluginWorkDirectoryURL,
            inputFiles: target.inputFiles.map(\.url).filter { $0.pathExtension.hasSuffix(".swift") },
            tool: try context.tool(named: "CodeOwnersTool")
        )
    }
}
#endif
