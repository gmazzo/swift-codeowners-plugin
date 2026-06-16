import PackagePlugin
import Foundation

@main
struct CodeOwnersMacroPlugin: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        return try buildCommands(
            targetName: target.name,
            root: context.package.directoryURL,
            workingDir: context.pluginWorkDirectoryURL,
            tool: try context.tool(named: "CodeOwnersMacroTool")
        )
    }

    private func buildCommands(targetName: String, root: URL, workingDir: URL, tool: PackagePlugin.PluginContext.Tool) throws -> [Command] {
        guard let inputs = Inputs.lookup(atRoot: root) else {
            Diagnostics.error("Failed to infer CODEOWNERS file root for target \(targetName): \(root)")
            return []
        }

        let resolved = try inputs.resolve()
        let macroFile = workingDir.appendingPathComponent("CodeOwnersMacro.swift")

        if ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode" {
            // FIXME Xcode early fails due missing output file, before running `.buildCommand`
            //  so we also run the macro generation here as a workaround.
            try generateMacro(
                codeOwnersRoot: resolved.codeOwnersRoot,
                codeOwnersFile: resolved.codeOwnersFile,
                renames: resolved.renames.asDict(),
                outputMacroFile: macroFile,
                verbose: resolved.verbose
            )
        }

        return [.buildCommand(
            displayName: "Generate CodeOwners macro implementation",
            executable: tool.url,
            arguments: [
                "-r", resolved.codeOwnersRoot.path,
                "-c", resolved.codeOwnersFile.path,
                macroFile.path,
            ] + (resolved.verbose ? ["--verbose"] : []),
            inputFiles: inputs.files,
            outputFiles: [macroFile]
        )]
    }

}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension CodeOwnersMacroPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        return try buildCommands(
            targetName: target.displayName,
            root: context.xcodeProject.directoryURL,
            workingDir: context.pluginWorkDirectoryURL,
            tool: try context.tool(named: "CodeOwnersMacroTool")
        )
    }
}
#endif
