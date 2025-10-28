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
        
        // FIXME apparenly Xcode fails to run the `.buildCommand` when a `BuildToolPlugin` is applied to a `.macro` project
        //  so we run manually the tool once now
        if ProcessInfo.processInfo.environment["__CFBundleIdentifier"] != nil {
            Diagnostics.warning("Xcode does not fully supports build plugins on macro targets. CODEOWNERS may not be updated unless you do a clean build")
            
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
