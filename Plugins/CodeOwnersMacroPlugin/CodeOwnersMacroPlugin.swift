import PackagePlugin
import Foundation

@main
struct CodeOwnersPlugin: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let inputs = Inputs.lookup(atRoot: context.package.directoryURL) else {
            Diagnostics.error("Failed to infer CODEOWNERS file root for target \(target.name)")
            return []
        }
        
        let tool = try context.tool(named: "CodeOwnersMacroTool")
        let resolved = try inputs.resolve()
        let macroFile = context.pluginWorkDirectoryURL.appendingPathComponent("CodeOwnersMacro.swift")
        
        if ProcessInfo.processInfo.environment["__CFBundleIdentifier"] == "com.apple.dt.Xcode" {
            // FIXME Xcode early fails due missing output file, before running `.buildCommand`
            //  so we also run the macro generation here as a workaround.
            try generateMacro(
                codeOwnersRoot: resolved.codeOwnersRoot,
                codeOwnersFile: resolved.codeOwnersFile,
                renames: resolved.renames.asDict(),
                outputMacroFile: macroFile
            )
        }

        return [.buildCommand(
            displayName: "Generate CodeOwners macro implementation",
            executable: tool.url,
            arguments: [
                "-r", resolved.codeOwnersRoot.path,
                "-c", resolved.codeOwnersFile.path,
                macroFile.path,
            ],
            inputFiles: inputs.files,
            outputFiles: [macroFile]
        )]
    }

}
