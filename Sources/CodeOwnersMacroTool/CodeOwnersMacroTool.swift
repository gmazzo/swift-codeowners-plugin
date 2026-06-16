import PathKit
import ArgumentParser
import CodeOwners
import CodeOwnersResolver

private let defaults = try! Inputs.lookupAlways().resolve()

@main
struct CodeOwnersMacroTool: AsyncParsableCommand {
    
    static let configuration: CommandConfiguration = .init(
        commandName: "swift-codeowners-macro",
        abstract: "Generates code ownership macro implementation"
    )
    
    @Option(name: [.long, .customShort("r")], help: "The root directory where the CODEOWNERS file patterns are based from.")
    var codeOwnersRoot: Path = Path(defaults.codeOwnersRoot)
    
    @Option(name: .shortAndLong, help: "The CODEOWNERS file to use for determining ownership.")
    var codeOwnersFile: Path = Path(defaults.codeOwnersFile)
    
    @Argument(help: "The path to store the generated macro file output")
    var outputMacroFile: Path = Path.current + "GeneratedSources/CodeOwnersMacro.swift"
    
    @Option(name: [.customLong("rename")], help: "Regex pattern to rename ownership names, in <regex>=<replacement> format)")
    var renames: [RenameRule] = defaults.renames
    
    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Enable verbose output for debugging purposes.")
    var verbose: Bool = defaults.verbose

    func run() throws {
        try generateMacro(
            codeOwnersRoot: codeOwnersRoot.url,
            codeOwnersFile: codeOwnersFile.url,
            renames: renames.asDict(),
            outputMacroFile: outputMacroFile.url,
            verbose: verbose
        )
    }
}
