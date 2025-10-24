import PackagePlugin
import Foundation

@main
struct CodeOwnersPlugin: BuildToolPlugin {

    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        guard let swiftTarget = target as? SwiftSourceModuleTarget else {
            Diagnostics.error("Target \(target.name) is not a Swift source module.")
            return []
        }

        let inputFiles = swiftTarget.sourceFiles(withSuffix: ".swift").map(\.url)
        if (inputFiles.isEmpty) {
            Diagnostics.warning("Target \(target.name) does not contain any Swift source files.")
            return []
        }

        let tool = try context.tool(named: "CodeOwnersTool")
        let outputFile = context.pluginWorkDirectoryURL.appendingPathComponent("CodeOwners.swift")
        let extraArgs = try toolArgsFromSettings(context.package.directoryURL.appending(component: ".codeowners-tool.json"))

        return [.buildCommand(
            displayName: "CodeOwner attribution",
            executable: tool.url,
            arguments: inputFiles.map(\.path) + ["--output-file", outputFile.path] + extraArgs,
            inputFiles: inputFiles,
            outputFiles: [outputFile]
        )]
    }
    
    private func toolArgsFromSettings(_ settingsFile: URL) throws -> [String] {
        if !FileManager.default.fileExists(atPath: settingsFile.path) { return [] }
        
        let data = try Data(contentsOf: settingsFile)
        let settings = try JSONDecoder().decode(Settings.self, from: data)
        
        var args: [String] = []
        if let root = settings.codeowners?.root { args += ["--codeOwnersRoot", root] }
        if let file = settings.codeowners?.file { args += ["--codeOwnersFile", file] }
        if let renames = settings.renames { args += renames.flatMap { (regEx, replacement) in ["--rename", "\(regEx)=\(replacement)"] } }
        if let quiet = settings.quiet { args.append(quiet ? "--quiet" : "--no-quiet") }
        if let verbose = settings.verbose { args.append(verbose ? "--verbose" : "--no-verbose") }
        return args
    }

}
