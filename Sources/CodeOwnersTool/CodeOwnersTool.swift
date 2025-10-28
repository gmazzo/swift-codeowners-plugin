import Foundation
import ArgumentParser
import CodeOwners
import CodeOwnersResolver
import SwiftParser

private let defaults = try! Inputs.lookupAlways().resolve()

@main
struct CodeOwnersTool: AsyncParsableCommand {
    
    static let configuration: CommandConfiguration = .init(
        commandName: "swift-codeowners",
        abstract: "Generates code ownership information into Swift files"
    )
    
    @Argument(help: "The Swift source files to process")
    var sources: [URL]
    
    @Option(name: [.long, .customShort("r")], help: "The root directory where the CODEOWNERS file patterns are based from.")
    var codeOwnersRoot: URL = defaults.codeOwnersRoot
    
    @Option(name: .shortAndLong, help: "The CODEOWNERS file to use for determining ownership.")
    var codeOwnersFile: URL = defaults.codeOwnersFile
    
    @Option(name: .shortAndLong, help: "The path to store the generated output CodeOwners attribution file")
    var outputFile: URL = FileManager.default.currentDirectory.appendingPathComponent("GeneratedSources/CodeOwners.swift")
    
    @Option(name: [.customLong("rename")], help: "Regex pattern to rename ownership names, in <regex>=<replacement> format)")
    var renames: [RenameRule] = defaults.renames
    
    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Enable verbose output for debugging purposes.")
    var verbose: Bool = defaults.verbose
    
    @Flag(name: .shortAndLong, inversion: .prefixedNo, help: "Suppress non-error output.")
    var quiet: Bool = defaults.quiet
    
    func run() throws {
        if (quiet && verbose) {
            print("Cannot use --quiet and --verbose flags together.", to: &stdErr)
            return
        }
        if (sources.isEmpty) {
            print("No source files provided.", to: &stdErr)
            return
        }
        
        let fm = FileManager.default
        if (!fm.fileExists(atPath: codeOwnersFile.path)) {
            print("CODEOWNERS file not found at path: \(codeOwnersFile.path).", to: &stdErr)
            return
        }
        
        let resolver = try resolveCodeOwners(
            file: codeOwnersFile,
            root: codeOwnersRoot,
            renames: renames
        )
        
        var mappings: [Substring: Set<String>] = [:]
        
        try fm.walkFiles(at: sources) { sourceFile in
            if sourceFile.pathExtension != "swift" { return }
            if verbose { print("Processing source file: \(sourceFile.relativePath)") }
            
            guard let owners = resolver.codeOwnersOf(sourceFile) else { return }
            
            do {
                for typeName in try collectTypes(from: sourceFile) {
                    mappings[typeName] = (mappings[typeName] ?? []).union(owners)
                }

            } catch {
                print("warning: Failed to process source file '\(sourceFile.relativePath)': \(error)", to: &stdErr)
            }
        }
        
        let content = generateContent(mappings)
        try fm.createDirectory(at: outputFile.deletingLastPathComponent(), withIntermediateDirectories: true)
        try content.write(to: outputFile, atomically: true, encoding: .utf8)
        
        if (!quiet) {
            print("Generated CodeOwners attribution for \(mappings.count) types at: \(outputFile.path)")
        }
    }

    private func collectTypes(from source: URL) throws -> Set<Substring> {
        let swiftFileContent = try String(contentsOf: source, encoding: .utf8)
        let swiftFile = Parser.parse(source: swiftFileContent)
        let collector = TypesCollector(viewMode: .fixedUp)
        collector.walk(swiftFile)
        return collector.rootTypes
    }
    
    private func generateContent(_ mappings: [Substring: Set<String>]) -> String {
        if mappings.isEmpty { return "" }
        
        var content = """
        import CodeOwnersAPI
        
        internal class _CodeOwners : CodeOwnersMappingProvider {
            static let codeOwners: [Substring: CodeOwners]? = [
        
        """
        for typeName in mappings.keys.sorted() {
            let owners = mappings[typeName]!.sorted().map { "\"\($0)\"" }.joined(separator: ", ")
            
            content += "        \"\(typeName)\": [\(owners)],\n"
        }
        content += """
        ]
    }
    
    """
        return content
    }
}

private func asRenameRule(regex: String, replace: String) -> RenameRule {
    let argument = "\(regex)=\(replace)"
    if let rule = RenameRule(argument: argument) { return rule }
    fatalError("Rename rule should be in the <regex>=<replacement> format: \(argument)")
}
